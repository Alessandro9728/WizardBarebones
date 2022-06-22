data "archive_file" "read_wizard_instance" {
  type        = "zip"
  output_path = "assets/read_wizard_instance.zip"
  source_dir = "./lambdas/DBRead/src/dist"
}

resource "aws_lambda_function" "read_wizard_instance" {
  function_name    = "read-wizard-instance"
  runtime          = "nodejs14.x"
  handler          = "index.lambdaHandler"
  filename         = data.archive_file.read_wizard_instance.output_path
  source_code_hash = data.archive_file.read_wizard_instance.output_base64sha256

  role = aws_iam_role.read_wizard_lambda_role.arn
}

