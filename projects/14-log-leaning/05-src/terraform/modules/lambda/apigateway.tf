resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = var.api_protocol_type

  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
    expose_headers = var.cors_expose_headers
    max_age       = var.cors_max_age
  }

  tags = merge(var.tags, {
    Name = var.api_name
  })
}

resource "aws_apigatewayv2_integration" "lambda_proxy" {
  api_id = aws_apigatewayv2_api.this.id

  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.this.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = var.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_proxy.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = var.auto_deploy

  default_route_settings {
    detailed_metrics_enabled = var.detailed_metrics_enabled
    logging_level            = var.apigw_logging_level
  }

  tags = merge(var.tags, {
    Name = "${var.api_name}-${replace(var.stage_name, "$", "")}"
  })
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
