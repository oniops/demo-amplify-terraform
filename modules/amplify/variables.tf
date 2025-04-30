variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'"
}

variable "amplify_repository" {
  type        = string
  default     = "https://github.com/clouddrove-sandbox/terraform-aws-amplify-app"
  description = "The repository for the Amplify app"
}

variable "description" {
  type        = string
  description = "The description for the Amplify app"
  default     = null
}

variable "platform" {
  type        = string
  description = "The platform or framework for the Amplify app"
  default     = "WEB"
}

variable "domain_name" {
  type        = list(any)
  default     = []
  description = "Domain name for the domain association."
}

variable "access_token" {
  type        = string
  default     = "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"
  description = "Personal access token for a third-party source"
}

variable "oauth_token" {
  type        = string
  description = <<-EOT
    The OAuth token for a third-party source control system for the Amplify app.
    The OAuth token is used to create a webhook and a read-only deploy key.
    The OAuth token is not stored.
    EOT
  default     = null
  sensitive   = true
}

variable "enable_auto_branch_creation" {
  type        = bool
  description = "Enables automated branch creation for the Amplify app"
  default     = false
}

variable "backend_enable" {
  type        = bool
  description = "Enables backend environment creation for the Amplify app"
  default     = false
}

variable "enable_basic_auth" {
  type        = bool
  description = <<-EOT
    Enables basic authorization for the Amplify app.
    This will apply to all branches that are part of this app.
    EOT
  default     = false
}

variable "auto_branch_creation_patterns" {
  type        = list(string)
  description = "The automated branch creation glob patterns for the Amplify app"
  default     = []
}

variable "enable_branch_auto_build" {
  type        = bool
  description = "Enables auto-building of branches for the Amplify App"
  default     = true
}

variable "enable_branch_auto_deletion" {
  type        = bool
  description = "Automatically disconnects a branch in the Amplify Console when you delete a branch from your Git repository"
  default     = false
}
variable "sub_domain_prefix_name" {
  type        = string
  default     = "scam"
  description = "Prefix setting for the subdomain."
}

variable "auto_branch_creation_config" {
  type = object({
    basic_auth_credentials        = optional(string)
    build_spec                    = optional(string)
    enable_auto_build             = optional(bool)
    enable_basic_auth             = optional(bool)
    enable_performance_mode       = optional(bool)
    enable_pull_request_preview   = optional(bool)
    environment_variables         = optional(map(string))
    framework                     = optional(string)
    pull_request_environment_name = optional(string)
    stage                         = optional(string)
  })
  description = "The automated branch creation configuration for the Amplify app"
  default     = null
}

variable "amplify_enabled" {
  type        = bool
  default     = true
  description = "Flag to control the amplify creation."
}

variable "environment_name" {
  type        = string
  default     = "prod"
  description = " Amplify environment name for the pull request."
}

variable "deployment_artifacts" {
  type        = string
  default     = "app-example-deployment"
  description = "Name of deployment artifacts."
}
variable "build_spec" {
  type        = string
  description = <<-EOT
    The [build specification](https://docs.aws.amazon.com/amplify/latest/userguide/build-settings.html) (build spec) for the Amplify app.
    If not provided then it will use the `amplify.yml` at the root of your project / branch.
    EOT
  default     = null
}
variable "stack_name" {
  type        = string
  default     = "amplify-app-example"
  description = "AWS CloudFormation stack name of a backend environment."
}

variable "custom_rules" {
  type = list(object({
    condition = optional(string)
    source    = string
    status    = optional(string)
    target    = string
  }))
  default     = []
  nullable    = false
  description = "The custom rules to apply to the Amplify App"
}

variable "amplify_app_environment_variables" {
  type        = map(string)
  description = "The environment variables for the Amplify app"
  default     = {}
}

variable "branches" {
  description = "List of branches to configure"
  type = list(object({
    branch_name       = string
    display_name      = string
    description       = string
    framework         = string
    stage             = string
    enable_auto_build = bool
    ttl               = number
    domain_prefix     = string
  }))
}