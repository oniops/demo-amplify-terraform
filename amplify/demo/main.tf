module "amplify" {
  source = "../../modules/amplify"

  name        = var.name
  description = "Managed via Terraform"
  environment = "main"
  label_order = ["name", "environment"]

  amplify_enabled  = true
  environment_name = "PROD"
  platform         = "WEB"

  auto_branch_creation_config = {
    enable_auto_build = true
  }
  enable_auto_branch_creation = true
  enable_basic_auth           = false
  enable_branch_auto_build    = true
  enable_branch_auto_deletion = true

  auto_branch_creation_patterns = [
    "main",
    "dev"
  ]

  domain_name          = [var.domain_name]
  amplify_repository   = var.github_url
  access_token         = data.aws_ssm_parameter.this.value
  deployment_artifacts = "demo-amplify-react"

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

  branches = [
    {
      branch_name   = "main"
      display_name  = "main"
      description   = "Main branch"
      framework     = "React"
      stage         = "PRODUCTION"
      enable_auto_build = true
      ttl           = 5
      domain_prefix = null
    },
    {
      branch_name   = "dev"
      display_name  = "dev"
      description   = "Development branch"
      framework     = "React"
      stage         = "DEVELOPMENT"
      enable_auto_build = true
      ttl           = 5
      domain_prefix = "dev"
    }
#    {
#      branch_name   = "feature/F101"
#      display_name  = "feature-f101"
#      description   = "feature branch"
#      framework     = "React"
#      stage         = "PULL_REQUEST"
#      enable_auto_build = true
#      ttl           = 5
#      domain_prefix = null
#    }
  ]

  custom_rules = [
    {
      source = "/<*>"
      status = "404"
      target = "/index.html"
    }
  ]
}
