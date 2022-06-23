data "archive_file" "write_wizard_instance" {
  type        = "zip"
  output_path = "assets/write_wizard_instance.zip"
  source_dir = "./lambdas/DBWrite/src/dist"
}

data "aws_iam_policy_document" "cloudwatch_write_lambda_logging" {
  statement {
    actions = [ "logs:CreateLogStream", "logs:PutLogEvents" ]
    resources = [ "arn:aws:logs:*:*:*" ]
  }
}

data "aws_iam_policy_document" "write_lambda_exec" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "write_to_table" {
    statement {
      actions = [ "dynamodb:PutItem" ]
      resources = [ aws_dynamodb_table.wizard-runtime.arn ]
    }
  
}