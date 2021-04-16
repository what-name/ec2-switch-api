variable "project-name" {
  description = "Prefix for the deployed resources"
  default     = "cloud-gamer-automation"
}

variable "region" {
  description = "The AWS region"
  default     = "eu-central-1"
}

variable "lambda_python_runtime" {
  description = "The runtime version for Python Lambdas. Defaults to python3.8"
  default     = "python3.8"
}

variable "lambda_handler" {
  description = "The handler for the Lambda function. Defaults to main.lambda_handler"
  default     = "main.lambda_handler"
}

variable "lamdba_timeout" {
  description = "The default timeout for a Lambda function. Defaults to 3 seconds"
  default     = 3
}

variable "instance_id" {
  description = "The Instance ID of the target server"
}