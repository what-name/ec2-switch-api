## TO DO
# Create second uri path for turn_off
# Understand how the fuck this works

# Data
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Cloud Gamer REST API resource
resource "aws_api_gateway_rest_api" "ec2_switch" {
  name        = var.project_name
  description = "The API Gateway connected to the ${var.project_name} Lambda functions."
}

# Cloud Gamer resource
resource "aws_api_gateway_resource" "ec2_switch" {
  rest_api_id = aws_api_gateway_rest_api.ec2_switch.id
  parent_id   = aws_api_gateway_rest_api.ec2_switch.root_resource_id
  path_part   = var.project_name
}

## Turn On
# Turn On resource
resource "aws_api_gateway_resource" "turn_on" {
  rest_api_id = aws_api_gateway_rest_api.ec2_switch.id
  parent_id   = aws_api_gateway_resource.ec2_switch.id
  path_part   = "turn-on"
}

# Turn On method
resource "aws_api_gateway_method" "turn_on" {
  rest_api_id      = aws_api_gateway_rest_api.ec2_switch.id
  resource_id      = aws_api_gateway_resource.turn_on.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

# Turn On lambda integration
resource "aws_api_gateway_integration" "turn_on" {
  rest_api_id = aws_api_gateway_rest_api.ec2_switch.id
  resource_id = aws_api_gateway_method.turn_on.resource_id
  http_method = aws_api_gateway_method.turn_on.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_on.invoke_arn
}

## Turn Off
# Turn Off resource
resource "aws_api_gateway_resource" "turn_off" {
  rest_api_id = aws_api_gateway_rest_api.ec2_switch.id
  parent_id   = aws_api_gateway_resource.ec2_switch.id
  path_part   = "turn-off"
}

# Turn Off method
resource "aws_api_gateway_method" "turn_off" {
  rest_api_id      = aws_api_gateway_rest_api.ec2_switch.id
  resource_id      = aws_api_gateway_resource.turn_off.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

# Turn Off lambda integration
resource "aws_api_gateway_integration" "turn_off" {
  rest_api_id = aws_api_gateway_rest_api.ec2_switch.id
  resource_id = aws_api_gateway_method.turn_off.resource_id
  http_method = aws_api_gateway_method.turn_off.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_off.invoke_arn
}

# Test deployment
resource "aws_api_gateway_deployment" "development" {
  rest_api_id = aws_api_gateway_rest_api.ec2_switch.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.ec2_switch.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.turn_on,
    aws_api_gateway_integration.turn_on
  ]
}

resource "aws_api_gateway_stage" "development" {
  deployment_id = aws_api_gateway_deployment.development.id
  rest_api_id   = aws_api_gateway_rest_api.ec2_switch.id
  stage_name    = "development"
}

# Turn On Lambda permission
resource "aws_lambda_permission" "turn_on" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_on.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.ec2_switch.execution_arn}/*/*" #FIXME how to tighten this?
}

# Turn Off Lambda permission
resource "aws_lambda_permission" "turn_off" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_off.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.ec2_switch.execution_arn}/*/*" #FIXME how to tighten this?
}

resource "aws_api_gateway_api_key" "ec2_switch" {
  name = "ec2_switch"
}

resource "aws_api_gateway_usage_plan" "ec2_switch" {
  name        = "${var.project_name}-secure-api"
  description = "Restricts access to the API with an API key."
  #product_code = "MYCODE"

  api_stages {
    api_id = aws_api_gateway_rest_api.ec2_switch.id
    stage  = aws_api_gateway_stage.development.stage_name
  }

  # api_stages {
  #   api_id = aws_api_gateway_rest_api.example.id
  #   stage  = aws_api_gateway_stage.production.stage_name
  # }

  quota_settings {
    limit  = 200
    offset = 0
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 20
    rate_limit  = 30
  }
}

resource "aws_api_gateway_usage_plan_key" "ec2_switch" {
  key_id        = aws_api_gateway_api_key.ec2_switch.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.ec2_switch.id
}
