output "lambda_on_archive_output_path" {
  value = data.archive_file.lambda_on.output_path
}

output "apigw_root_url" {
  value = "${aws_api_gateway_deployment.development.invoke_url}/development/"
}

output "apigw_api_key" {
  value = "The API key can be retrieved from the AWS console."
}