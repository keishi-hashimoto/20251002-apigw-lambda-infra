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

variable "lambda_permission_statement_id" {
  type        = string
  description = "Statement ID"
}

variable "ssh_bucket_name" {
  type        = string
  description = "Bucket name for static site hosting"
}

variable "index_document" {
  type = string
}

variable "error_page" {
  type = string
}