data "archive_file" "read_wizard_instance" {
  type        = "zip"
  output_path = "assets/read_wizard_instance.zip"
  source_dir = "./lambdas/DBRead/src/dist"
}

data "aws_iam_policy_document" "cloudwatch_read_lambda_logging" {
  statement {
    actions = [ "logs:CreateLogStream", "logs:PutLogEvents" ]
    resources = [ "arn:aws:logs:*:*:*" ]
  }
}

data "aws_iam_policy_document" "read_lambda_exec" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "read_from_table" {
    statement {
      actions = [ "dynamodb:GetItem" ]
      resources = [ aws_dynamodb_table.wizard-runtime.arn ]
    }
  
}