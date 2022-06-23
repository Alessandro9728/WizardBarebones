variable "account_id" {
  description = "AWS account id"
  type        = string
  default = "778951600279"
}

variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default = "eu-west-1"
}

resource "aws_iam_policy" "api_gateway_permissions" {
  name   = "APIGateway-Permissions"
  policy = data.aws_iam_policy_document.api_gateway.json
}

data "aws_iam_policy_document" "api_gateway" {
  statement {
    sid = "APIGatewayInvokeFunctions"

    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      aws_lambda_function.read_wizard_instance.arn,
      aws_lambda_function.write_wizard_instance.arn
    ]
  }
}

data "aws_iam_policy_document" "api_gateway_trust_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_gateway" {
  name               = "APIGateway-Role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "api_gateway_permissions" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = aws_iam_policy.api_gateway_permissions.arn
}

resource "aws_api_gateway_rest_api" "wizard_api_gateway" {
  name = "wizard-api-gateway"
  disable_execute_api_endpoint = false

  body = templatefile(
    "./swagger/wizard_api.yaml",
    {
      account-id              = var.account_id
      region                  = var.region
      role-arn           = aws_iam_role.api_gateway.arn
      lambda-write-wizard-instance = aws_lambda_function.write_wizard_instance.function_name
      lambda-read-wizard-instance = aws_lambda_function.read_wizard_instance.function_name
      cognito-userpool-arn = aws_cognito_user_pool.cognito_user_pool.arn
    }
  )
}
/*
resource "aws_api_gateway_resource" "wizard_instances" {
  parent_id   = aws_api_gateway_rest_api.wizard_api_gateway.root_resource_id
  path_part   = "wizard-instances"
  rest_api_id = aws_api_gateway_rest_api.wizard_api_gateway.id
}

resource "aws_api_gateway_resource" "wizard_instance" {
  parent_id   = aws_api_gateway_resource.wizard_instances.id
  path_part   = "{wizardInstance}"
  rest_api_id = aws_api_gateway_rest_api.wizard_api_gateway.id
}

resource "aws_api_gateway_method" "read_from_table" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.wizard_instance.id
  rest_api_id   = aws_api_gateway_rest_api.wizard_api_gateway.id

  request_parameters = {
    "method.request.path.wizardInstance" = true
  }
}

resource "aws_api_gateway_method" "write_to_table" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.wizard_instances.id
  rest_api_id   = aws_api_gateway_rest_api.wizard_api_gateway.id
}

resource "aws_api_gateway_integration" "wizard_api_gateway_read_int" {
  http_method             = aws_api_gateway_method.read_from_table.http_method
  resource_id             = aws_api_gateway_resource.wizard_instance.id
  rest_api_id             = aws_api_gateway_rest_api.wizard_api_gateway.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.read_wizard_instance.invoke_arn
  request_parameters = {
      "integration.request.path.id" = "method.request.path.wizardInstance"
  }
}

resource "aws_api_gateway_integration" "wizard_api_gateway_write_int" {
  http_method             = aws_api_gateway_method.write_to_table.http_method
  resource_id             = aws_api_gateway_resource.wizard_instances.id
  rest_api_id             = aws_api_gateway_rest_api.wizard_api_gateway.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.write_wizard_instance.invoke_arn
}
*/

resource "aws_api_gateway_deployment" "wizard_api_gateway_depl" {
  rest_api_id = aws_api_gateway_rest_api.wizard_api_gateway.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    /*
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.wizard_instances.id,
      aws_api_gateway_resource.wizard_instance.id,
      aws_api_gateway_method.write_to_table,
      aws_api_gateway_method.read_from_table,
      aws_api_gateway_integration.wizard_api_gateway_write_int.id,
      aws_api_gateway_integration.wizard_api_gateway_read_int.id,
    ]))*/
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.wizard_api_gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "wizard_api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.wizard_api_gateway_depl.id
  rest_api_id   = aws_api_gateway_rest_api.wizard_api_gateway.id
  stage_name    = "wizard-dev"
}

resource "aws_api_gateway_usage_plan" "default_usage_plan" {
  name = "wizard-api-gateway-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.wizard_api_gateway.id
    stage  = aws_api_gateway_stage.wizard_api_gateway_stage.stage_name
  }
}

//Cognito Resources
resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = "user-pool"

  username_attributes = ["email"]
  password_policy {
    minimum_length = 6
  }
  
}

resource "aws_cognito_user" "userDS" {
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
  username     = "userDS@gmail.com"
  password = "setpw1"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "cognito-client"

  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
  explicit_auth_flows = [ "USER_PASSWORD_AUTH" ]
}

