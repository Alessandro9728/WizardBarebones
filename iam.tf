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

data "aws_iam_policy_document" "read_from_table" {
    statement {
      actions = [ "dynamodb:GetItem" ]
      resources = [ aws_dynamodb_table.wizard-runtime.arn ]
    }
  
}

resource "aws_iam_policy" "read_from_table" {
  name = "read-from-table-policy"
  policy = data.aws_iam_policy_document.read_from_table.json
}

resource "aws_iam_role_policy_attachment" "read_from_table" {
    policy_arn = aws_iam_policy.read_from_table.arn
    role = aws_iam_role.read_wizard_lambda_role.name
}

data "aws_iam_policy_document" "cloudwatch_lambda_logging" {
  statement {
    actions = [ "logs:CreateLogStream", "logs:PutLogEvents" ]
    resources = [ "arn:aws:logs:*:*:*" ]
  }
}

resource "aws_iam_policy" "cloudwatch_lambda_logging" {
  name = "clodwatch_lambda_logging"
  policy = data.aws_iam_policy_document.cloudwatch_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "write_lambda_logging" {
    policy_arn = aws_iam_policy.cloudwatch_lambda_logging.arn
    role = aws_iam_role.read_wizard_lambda_role.name
}

resource "aws_iam_role_policy_attachment" "read_lambda_logging" {
    policy_arn = aws_iam_policy.cloudwatch_lambda_logging.arn
    role = aws_iam_role.write_wizard_lambda_role.name
}

