resource "aws_dynamodb_table" "wizard-runtime" {

  name = "WIZARD-RUNTIME"

  hash_key = "wizard-instance"

  billing_mode = "PROVISIONED"

  read_capacity = 10

  write_capacity = 10



  attribute {

    name = "wizard-instance"

    type = "S"

  }


}