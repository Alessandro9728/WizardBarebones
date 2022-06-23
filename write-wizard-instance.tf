resource "aws_lambda_function" "write_wizard_instance" {
  function_name    = "writewizardinstance"
  runtime          = "nodejs14.x"
  handler          = "index.lambdaHandler"
  filename         = data.archive_file.write_wizard_instance.output_path
  source_code_hash = data.archive_file.write_wizard_instance.output_base64sha256

  role = aws_iam_role.write_wizard_lambda_role.arn
}

resource "aws_cloudwatch_log_group" "write-wizard-cw" {

  name = "/aws/lambda/${aws_lambda_function.write_wizard_instance.function_name}"
  retention_in_days = 30

}


//IAM

resource "aws_iam_role" "write_wizard_lambda_role" {
  name               = "write-wizard-role"
  assume_role_policy = data.aws_iam_policy_document.write_lambda_exec.json
}

resource "aws_iam_policy" "write_to_table" {
  name = "write-to-table-policy"
  policy = data.aws_iam_policy_document.write_to_table.json
}

resource "aws_iam_role_policy_attachment" "write_to_table" {
    policy_arn = aws_iam_policy.write_to_table.arn
    role = aws_iam_role.write_wizard_lambda_role.name
}

resource "aws_iam_policy" "cloudwatch_write_lambda_logging" {
  name = "clodwatch_write_lambda_logging"
  policy = data.aws_iam_policy_document.cloudwatch_write_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "write_lambda_logging" {
    policy_arn = aws_iam_policy.cloudwatch_write_lambda_logging.arn
    role = aws_iam_role.read_wizard_lambda_role.name
}


