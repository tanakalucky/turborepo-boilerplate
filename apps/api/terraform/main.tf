data "local_file" "graphql_schema" {
  filename = "../schema.graphql"
}

resource "aws_appsync_graphql_api" "example" {
  name                = "example"
  authentication_type = "API_KEY"
  schema              = data.local_file.graphql_schema.content
}

resource "aws_appsync_api_key" "this" {
  api_id  = aws_appsync_graphql_api.example.id
  expires = timeadd(timestamp(), "365d")
}

resource "aws_iam_role" "appsync_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "appsync_policy" {
  role = aws_iam_role.appsync_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          module.lambda1.lambda_function_arn,
          module.lambda2.lambda_function_arn
        ]
      }
    ]
  })
}

resource "aws_appsync_datasource" "lambda1_datasource" {
  api_id           = aws_appsync_graphql_api.example.id
  name             = "lambda1_datasource"
  service_role_arn = aws_iam_role.appsync_role.arn
  type             = "AWS_LAMBDA"

  lambda_config {
    function_arn = module.lambda1.lambda_function_arn
  }
}

resource "aws_appsync_datasource" "lambda2_datasource" {
  api_id           = aws_appsync_graphql_api.example.id
  name             = "lambda2_datasource"
  service_role_arn = aws_iam_role.appsync_role.arn
  type             = "AWS_LAMBDA"

  lambda_config {
    function_arn = module.lambda2.lambda_function_arn
  }
}

data "local_file" "resolver_js" {
  filename = "../resolver.js"
}

resource "aws_appsync_resolver" "query_example" {
  api_id      = aws_appsync_graphql_api.example.id
  type        = "Query"
  field       = "test1"
  data_source = aws_appsync_datasource.lambda1_datasource.name
  kind        = "UNIT"
}

resource "aws_appsync_resolver" "mutation_example" {
  api_id      = aws_appsync_graphql_api.example.id
  type        = "Query"
  field       = "test2"
  data_source = aws_appsync_datasource.lambda2_datasource.name
  kind        = "UNIT"
}

module "lambda1" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.app_name}-lambda-function-1-${var.env}"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "../dist/test"

  attach_policies = true
  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSAppSyncInvokeFullAccess"
  ]
  number_of_policies = 2

}
module "lambda2" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.app_name}-lambda-function-2-${var.env}"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "../dist/test2"

  attach_policies = true
  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSAppSyncInvokeFullAccess"
  ]
  number_of_policies = 2
}
