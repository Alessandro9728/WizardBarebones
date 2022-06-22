resource "aws_cloudwatch_log_group" "read-wizard-cw" {

  name = "/aws/lambda/${aws_lambda_function.read_wizard_instance.function_name}"

  retention_in_days = 30

}



resource "aws_cloudwatch_log_group" "write-wizard-cw" {

  name = "/aws/lambda/${aws_lambda_function.write_wizard_instance.function_name}"

  retention_in_days = 30

}