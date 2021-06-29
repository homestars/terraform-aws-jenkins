config {
  module = true
  force = false
  disabled_by_default = false

  ignore_module = {
    "terraform-aws-modules/vpc/aws" = true
  }
}

plugin "aws" {
  enabled = true
  version = "0.4.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"

  #TODO generate creds and account so deep_check can be enabled
  #For now, you can uncomment the lines here to run deep tests locally
  #deep_check              = true
  #region                  = "us-east-1"
  #shared_credentials_file = "~/.aws/config"
  #profile                 = "hs-test-profile"
}

#terraform rules
rule "terraform_deprecated_interpolation" {
  enabled = true
}
rule "terraform_deprecated_index" {
  enabled = true
}
rule "terraform_unused_declarations" {
  enabled = true
}
rule "terraform_comment_syntax" {
  enabled = true
}
rule "terraform_documented_outputs" {
  enabled = true
}
rule "terraform_documented_variables" {
  enabled = true
}
rule "terraform_typed_variables" {
  enabled = true
}
rule "terraform_module_pinned_source" {
  enabled = true
}
rule "terraform_naming_convention" {
  enabled = true
}
rule "terraform_required_version" {
  enabled = true
}
rule "terraform_required_providers" {
  enabled = true
}
rule "terraform_unused_required_providers" {
  enabled = true
}
rule "terraform_standard_module_structure" {
  enabled = true
}
rule "terraform_workspace_remote" {
  enabled = true
}

#aws rules
rule "aws_iam_policy_document_gov_friendly_arns" {
  enabled = true
}
rule "aws_iam_policy_gov_friendly_arns" {
  enabled = true
}
rule "aws_iam_role_policy_gov_friendly_arns" {
  enabled = true
}
