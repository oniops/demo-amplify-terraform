# AWS Amplify Terraform 모듈

이 Terraform 모듈은 AWS Amplify 애플리케이션의 전체 구성을 자동화합니다.

Amplify 앱 생성부터 Git 리포지토리 연동, 브랜치 연결, CI/CD 설정, 커스텀 도메인 매핑, 빌드 사양 정의, 웹훅 생성까지 포함됩니다.


## 사전 준비 사항
#### Git Provider 액세스 토큰 발급 
- 진행하기 전에 각 Git Provider에서 Personal access tokens을 발급받아야 합니다. 이 토큰은 Terraform이 Git 리포지토리에 접근하는 데 사용됩니다.
- 아래는 각 Git Provider에서 토큰값을 받아오는 방법입니다.

| Git provider |                                 Process                                  |
|:------------:|:------------------------------------------------------------------------:|
|    GitHub    | Your Profile -> Settings -> Developer Settings -> Personal Access Tokens |
|  BitBucket   | Your Profile -> View profile -> Manage Account -> Personal Access Tokens |
|    GitLab    |               Your Profile -> Preferences -> Access Tokens               |                                         |

>  Note: 토큰을 발급받을 때 최소한 repository 접근 권한을 부여해야 합니다.
> 
> Permissions
> - Write access to files located at amplify.yml
>
> - Read access to code and metadata
>
> - Read and write access to checks, pull requests, and repository hooks

## Checkout
```
# git clone 
git clone https://github.com/oniops/demo-amplify-terraform.git

# 루트 디렉토리 환경 변수로 저장
export BASE_DIR=$(git rev-parse --show-toplevel)

# move to dir
cd $BASE_DIR/amplify/demo
```

## 모듈 설치 및 설정
### Usage
- `demo.tfvars` 파일을 수정하여 애플리케이션 설정을 지정합니다.
```
name        = "demo-amplify-app"                     # The name of your Amplify app
domain_name = "example.com"                          # Your custom domain to connect
github_url  = "https://github.com/org/repo"          # Your Git provider repository URL
```

- `main.tf` 파일을 수정하여 애플리케이션 설정을 지정합니다. 
```
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
```

### Build & Deployment
```
# Git 토큰 환경 변수 설정
export TF_VAR_github_private_access_token="github_pat_xxxxxxxxxxxxx"

# Init
terraform init -upgrade

# Plan
sh deploy.sh plan

# Deploy
sh deploy.sh apply
```

## 배포 후 작업
#### GitHub 토큰 관리

> **중요** 
> 
> 1. GitHub 개인 액세스 토큰(PAT)은 **오직 초기 설정 단계에서만 필요**합니다. Amplify가 정상적으로 프로비저닝되면 즉시 토큰을 삭제해야 합니다.
> 
> 2. tfstate 파일에서 "access_token": "github_pat_xxxxxxxxxxxxx" 부분도 반드시 제거해야 합니다. 

#### 동작 방식

1. 초기 연결 단계 : GitHub 개인 액세스 토큰(PAT)은 오직 Terraform이 처음 Amplify 앱을 생성하고 GitHub 리포지토리와 연결할 때만 사용됩니다.
2. GitHub App으로 자동 전환: 초기 설정이 완료되면 AWS Amplify는 자동으로 GitHub Apps 기능을 사용하여 리포지토리에 접근합니다. 이때부터 개인 액세스 토큰은 더 이상 필요하지 않습니다.
3. GitHub App은 개인 액세스 토큰보다 훨씬 안전한 방식으로, 특정 리포지토리에만 제한된 접근 권한을 부여하고 필요한 권한만 정밀하게 설정할 수 있습니다.

#### GitHub App 인증 프로세스

##### JWT 생성:
- AWS Amplify App 프로비저닝 될 때 GitHub App이 자체적으로 JWT(JSON Web Token)를 생성
- JWT는 GitHub API와 통신하기 위한 식별자 역할을 하며, App ID, 발행 시간(iat), 만료 시간(exp) 등의 정보가 포함됨

##### 설치 토큰 획득
- GitHub App은 생성한 JWT를 사용해 GitHub API에 요청을 보내고, GitHub API는 이 JWT를 검증한 뒤 해당 앱의 설치 정보를 반환
- 이 과정에서 특정 리포지토리에 접근할 수 있는 "설치 토큰(Installation Token)"이 Amplify App으로 발급됨

##### 리포지토리 접근
- AWS Amplify는 발급받은 설치 토큰을 사용해 GitHub 리포지토리에 접근하며, 이 토큰은 정기적으로 자동 갱신되어 보안 유지
