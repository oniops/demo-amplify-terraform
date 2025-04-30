# AWS Amplify Terraform 모듈

이 Terraform 모듈은 AWS Amplify 애플리케이션의 전체 구성을 자동화합니다.

Amplify 앱 생성부터 Git 리포지토리 연동, 브랜치 연결, CI/CD 설정, 커스텀 도메인 매핑, 빌드 사양 정의, 웹훅 생성까지 포함됩니다.


### 사전 준비 사항
- 진행하기 전에 각 Git Provider에서 Personal access tokens을 발급받으셔야 합니다.
- 토큰값을 가져와, Parameter Store에 등록한 후, 진행이 되어야합니다.
- 아래는 각 Git Provider에서 토큰값을 받아오는 방법입니다.

| Git provider |                                 Process                                  |
|:------------:|:------------------------------------------------------------------------:|
|    GitHub    | Your Profile -> Settings -> Developer Settings -> Personal Access Tokens |
|  BitBucket   |                                  ::TODO                                  |
|  CodeCommit  |                                  ::TODO                                  |                                   |
|    GitLab    |                                  ::TODO                                  |                                   |


### Checkout
```
# 리포지토리 클론
git clone https://github.com/oni-jisookim/demo-amplify-terraform.git

# 루트 디렉토리 환경 변수로 저장
export BASE_DIR=$(git rev-parse --show-toplevel)

# 모듈 디렉토리로 이동
cd $BASE_DIR/amplify/demo
```

### Usage
- amplify/demo/env/demo.tfvars
```
name        = "demo-amplify-app"                     # The name of your Amplify app
domain_name = "example.com"                          # Your custom domain to connect
github_url  = "https://github.com/org/repo"          # Your Git provider repository URL
ssm_name    = "/amplify/github/personal-access-token" # SSM path to your Git provider's PAT
```

- amplify/demo/main.tf
```
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
      domain_prefix = null # apex domain
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
  ]
  custom_rules = [
    {
      source = "/<*>"
      status = "404"
      target = "/index.html"
    }
  ]
}

```


### Build & Deployment
```
# Init
terraform init -upgrade

# Plan
sh deploy.sh plan

# Deploy
sh deploy.sh apply
```

