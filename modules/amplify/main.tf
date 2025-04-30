locals {
  domain_branches = [
    for b in var.branches : {
      branch_name   = b.branch_name
      domain_prefix = b.domain_prefix
    } if contains(["main", "dev"], b.branch_name)
  ]
}

resource "aws_amplify_app" "this" {
  count = var.amplify_enabled ? 1 : 0

  name                          = var.name
  repository                    = var.amplify_repository
  description                   = var.description
  platform                      = var.platform
  auto_branch_creation_patterns = var.auto_branch_creation_patterns
  build_spec                    = var.build_spec

  environment_variables       = var.amplify_app_environment_variables
  access_token                = var.access_token
  oauth_token                 = var.oauth_token
  enable_auto_branch_creation = var.enable_auto_branch_creation
  enable_branch_auto_build    = var.enable_branch_auto_build
  enable_branch_auto_deletion = var.enable_branch_auto_deletion
  enable_basic_auth           = var.enable_basic_auth

  dynamic "custom_rule" {
    for_each = var.custom_rules
    content {
      condition = lookup(custom_rule.value, "condition", null)
      source    = custom_rule.value.source
      status    = lookup(custom_rule.value, "status", null)
      target    = custom_rule.value.target
    }
  }

  dynamic "auto_branch_creation_config" {
    for_each = var.auto_branch_creation_config != null ? [true] : []
    content {
      build_spec                  = lookup(var.auto_branch_creation_config, "build_spec", null)
      enable_auto_build           = lookup(var.auto_branch_creation_config, "enable_auto_build", null)
      enable_basic_auth           = lookup(var.auto_branch_creation_config, "enable_basic_auth", null)
      enable_performance_mode     = lookup(var.auto_branch_creation_config, "enable_performance_mode", null)
      enable_pull_request_preview = lookup(var.auto_branch_creation_config, "enable_pull_request_preview", null)
      environment_variables       = lookup(var.auto_branch_creation_config, "environment_variables", null)
      framework                   = lookup(var.auto_branch_creation_config, "framework", null)
      stage                       = lookup(var.auto_branch_creation_config, "stage", null)
    }
  }
}

resource "aws_amplify_branch" "this" {
  count = length(var.branches)

  app_id           = aws_amplify_app.this[0].id
  branch_name      = var.branches[count.index].branch_name
  display_name     = var.branches[count.index].display_name
  description      = var.branches[count.index].description
  framework        = var.branches[count.index].framework
  stage            = var.branches[count.index].stage
  enable_auto_build = var.branches[count.index].enable_auto_build
  ttl              = var.branches[count.index].ttl != null ? var.branches[count.index].ttl : 3600
}

resource "aws_amplify_domain_association" "this" {
  count       = length(var.domain_name)
  app_id      = aws_amplify_app.this[0].id
  domain_name = var.domain_name[count.index]

  dynamic "sub_domain" {
    for_each = local.domain_branches
    content {
      branch_name = sub_domain.value.branch_name
      prefix      = sub_domain.value.domain_prefix != null ? sub_domain.value.domain_prefix : ""
    }
  }
}

resource "aws_amplify_webhook" "main" {
  count         = length(var.branches)
  app_id        = aws_amplify_app.this[0].id
  branch_name   = var.branches[count.index].branch_name # Ensure this branch name is correct
  description   = "Webhook for ${var.branches[count.index].branch_name}"

  depends_on = [aws_amplify_branch.this]
}