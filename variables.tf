variable "function_name" {
  type        = string
  description = "lambda function name"
}

variable "lambda_exec_role" {
  type        = string
  description = "name of lambda exec role"
}

variable "api_gateway_name" {
  type        = string
  description = "API Gateway Name"
}
