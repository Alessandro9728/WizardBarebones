resource "aws_api_gateway_rest_api" "wizard_api_gateway" {
  name = "wizard-api-gateway"
}

resource "aws_api_gateway_resource" "wizard_api_gateway" {
  parent_id   = aws_api_gateway_rest_api.wizard_api_gateway.root_resource_id
  path_part   = "wizard-api-gateway"
  rest_api_id = aws_api_gateway_rest_api.wizard_api_gateway.id
}

resource "aws_api_gateway_method" "read_from_table" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.wizard_api_gateway.id
  rest_api_id   = aws_api_gateway_rest_api.wizard_api_gateway.id
}

resource "aws_api_gateway_method" "write_to_table" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.wizard_api_gateway.id
  rest_api_id   = aws_api_gateway_rest_api.wizard_api_gateway.id
}

resource "aws_api_gateway_integration" "wizard_api_gateway_read_int" {
  http_method             = aws_api_gateway_method.read_from_table.http_method
  resource_id             = aws_api_gateway_resource.wizard_api_gateway.id
  rest_api_id             = aws_api_gateway_rest_api.wizard_api_gateway.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.read_wizard_instance.invoke_arn
}

resource "aws_api_gateway_integration" "wizard_api_gateway_write_int" {
  http_method             = aws_api_gateway_method.write_to_table.http_method
  resource_id             = aws_api_gateway_resource.wizard_api_gateway.id
  rest_api_id             = aws_api_gateway_rest_api.wizard_api_gateway.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.write_wizard_instance.invoke_arn
}

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
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.wizard_api_gateway.id,
      aws_api_gateway_method.write_to_table,
      aws_api_gateway_method.read_from_table,
      aws_api_gateway_integration.wizard_api_gateway_write_int.id,
      aws_api_gateway_integration.wizard_api_gateway_read_int.id,
    ]))
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