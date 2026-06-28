# CloudWatch Logs resources for Lambda and API Gateway.

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.lambda_log_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.function_name}-logs"
  })
}

resource "aws_cloudwatch_log_group" "apigw_access" {
  count = var.enable_apigw_access_logs ? 1 : 0

  name              = "/aws/apigateway/${var.api_name}-${replace(var.stage_name, "$", "")}-access"
  retention_in_days = var.apigw_access_log_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.api_name}-access-logs"
  })
}
