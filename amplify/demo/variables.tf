variable "context" { type = any }
variable "name" { type = string }

variable "github_url" {
  type = string
}

variable "github_private_access_token" {
  type      = string
  default   = null
  sensitive = true
}

variable "domain_name" {
  type = string
}

variable "branch" {
  type = any
  description = <<-EOT
branch    = [
  {
    branch_name       = "main"
    display_name      = "main"
    description       = "Main branch"
    framework         = "React"
    stage             = "PRODUCTION" #["PRODUCTION" "BETA" "DEVELOPMENT" "EXPERIMENTAL" "PULL_REQUEST"]
    enable_auto_build = true
    domain_prefix     = null
  },
  {
    branch_name       = "dev"
    display_name      = "dev"
    description       = "Development branch"
    framework         = "React"
    stage             = "DEVELOPMENT"
    enable_auto_build = true
    domain_prefix     = "dev"
  }
]
    EOT
}