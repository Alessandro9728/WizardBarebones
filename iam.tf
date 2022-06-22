data "aws_iam_policy_document" "lambda_exec" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "read_wizard_lambda_role" {
  name               = "read-wizard-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec.json
}

resource "aws_iam_role" "write_wizard_lambda_role" {
  name               = "write-wizard-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec.json
}

data "aws_iam_policy_document" "write_to_table" {
    statement {
      actions = [ "dynamodb:PutItem" ]
      resources = [ aws_dynamodb_table.wizard-runtime.arn ]
    }
  
}

resource "aws_iam_policy" "write_to_table" {
  name = "write-to-table-policy"
  policy = data.aws_iam_policy_document.write_to_table.json
}

resource "aws_iam_role_policy_attachment" "write_to_table" {
    policy_arn = aws_iam_policy.write_to_table.arn
    role = aws_iam_role.write_wizard_lambda_role.name
}

resource "aws_lambda_permission" "allow_api_gateway_read" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read_wizard_instance.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.wizard_api_gateway.execution_arn}/*/GET/wizard-api-gateway"
}

resource "aws_lambda_permission" "allow_api_gateway_write" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.write_wizard_instance.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.wizard_api_gateway.execution_arn}/*/POST/wizard-api-gateway"
}

resource "aws_lambda_permission" "allow_cloudwatch_read" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read_wizard_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-west-1:778951600279:*/*"
}

resource "aws_lambda_permission" "allow_cloudwatch_write" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.write_wizard_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-west-1:778951600279:*/*"
}

