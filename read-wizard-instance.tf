resource "aws_lambda_function" "read_wizard_instance" {
  function_name    = "readwizardinstance"
  runtime          = "nodejs14.x"
  handler          = "index.lambdaHandler"
  filename         = data.archive_file.read_wizard_instance.output_path
  source_code_hash = data.archive_file.read_wizard_instance.output_base64sha256

  role = aws_iam_role.read_wizard_lambda_role.arn
}

resource "aws_cloudwatch_log_group" "read-wizard-cw" {

  name = "/aws/lambda/${aws_lambda_function.read_wizard_instance.function_name}"
  retention_in_days = 30

}



//IAM
resource "aws_iam_role" "read_wizard_lambda_role" {
  name               = "read-wizard-role"
  assume_role_policy = data.aws_iam_policy_document.read_lambda_exec.json
}

resource "aws_iam_policy" "read_from_table" {
  name = "read-from-table-policy"
  policy = data.aws_iam_policy_document.read_from_table.json
}

resource "aws_iam_role_policy_attachment" "read_from_table" {
    policy_arn = aws_iam_policy.read_from_table.arn
    role = aws_iam_role.read_wizard_lambda_role.name
}

resource "aws_iam_policy" "cloudwatch_read_lambda_logging" {
  name = "clodwatch_read_lambda_logging"
  policy = data.aws_iam_policy_document.cloudwatch_read_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "read_lambda_logging" {
    policy_arn = aws_iam_policy.cloudwatch_read_lambda_logging.arn
    role = aws_iam_role.write_wizard_lambda_role.name
}
