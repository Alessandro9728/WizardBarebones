data "archive_file" "write_wizard_instance" {
  type        = "zip"
  output_path = "assets/write_wizard_instance.zip"
  source_dir = "./lambdas/DBWrite/src/dist"
}

resource "aws_lambda_function" "write_wizard_instance" {
  function_name    = "writewizardinstance"
  runtime          = "nodejs14.x"
  handler          = "index.lambdaHandler"
  filename         = data.archive_file.write_wizard_instance.output_path
  source_code_hash = data.archive_file.write_wizard_instance.output_base64sha256

  role = aws_iam_role.write_wizard_lambda_role.arn
}