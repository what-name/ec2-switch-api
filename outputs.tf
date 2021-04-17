output "apigw_root_url" {
  description = "The API GW root URL."
  value = "${aws_api_gateway_deployment.development.invoke_url}development/"
}

output "apigw_turn_on_url" {
  description = "The turn on endpoint for the API."
  value = "${aws_api_gateway_deployment.development.invoke_url}development/${var.project_name}/turn_on"
}

output "apigw_turn_off_url" {
  description = "The turn off endpoint for the API."
  value = "${aws_api_gateway_deployment.development.invoke_url}development/${var.project_name}/turn_off"
}

output "apigw_api_key" {
  value = "The API key can be retrieved from the AWS console."
}