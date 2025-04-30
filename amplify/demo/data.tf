data "aws_ssm_parameter" "this" {
  name = var.ssm_name
}