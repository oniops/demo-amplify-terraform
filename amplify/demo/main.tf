module "ctx" {
  source          = "git::https://github.com/oniops/tfmodule-context.git?ref=v1.3.2"
  context         = var.context
  additional_tags = { AppName = var.name }
}

locals {
  account_id         = module.ctx.account_id
  region             = module.ctx.region
  name_prefix        = module.ctx.name_prefix
  tags               = module.ctx.tags
}

module "amplify" {
  amplify_enabled  = true

  source = "../../modules/amplify"

  name        = var.name

  auto_branch_creation_config = {
    enable_auto_build = true
  }
  enable_auto_branch_creation = false
  enable_basic_auth           = false
  enable_branch_auto_build    = true
  enable_branch_auto_deletion = true

  #auto_branch_creation_patterns = []

  domain_name          = [var.domain_name]
  amplify_repository   = var.github_url
  access_token         = var.github_private_access_token

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        build:
          commands:
            - echo Installing dependencies...
            - npm install
            - echo Building the React app...
            - npm run build
      artifacts:
        baseDirectory: /build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  branches = var.branch
  custom_rules = [
    {
      source = "/<*>"
      status = "404"
      target = "/index.html"
    }
  ]
}
