data "aws_cloudwatch_log_group" "lambda" {
  name = aws_lambda_function.main.logging_config[0].log_group
}