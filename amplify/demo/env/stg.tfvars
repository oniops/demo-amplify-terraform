name                        = "demo-amplify-react"
domain_name                 = "amply.onidemo.com"
github_url                  = "https://github.com/oniops/demo-amplify-react.git"
branch                      = [
  {
    branch_name       = "main"
    display_name      = "main"
    description       = "Main branch"
    framework         = "React"
    stage             = "PRODUCTION"
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
  #  {
  #    branch_name       = "feature/F101"
  #    display_name      = "feature-f101"
  #    description       = "feature branch"
  #    framework         = "React"
  #    stage             = "DEVELOPMENT"
  #    enable_auto_build = true
  #    domain_prefix     = null
  #  }
]