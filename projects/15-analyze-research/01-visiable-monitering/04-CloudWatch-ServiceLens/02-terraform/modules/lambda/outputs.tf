# lambda module outputs

output "lambda_function_name" {
  description = "Lambda関数名"
  value       = aws_lambda_function.this.function_name
}

output "lambda_function_arn" {
  description = "Lambda関数ARN"
  value       = aws_lambda_function.this.arn
}

output "lambda_invoke_arn" {
  description = "Lambda invoke ARN"
  value       = aws_lambda_function.this.invoke_arn
}

output "lambda_role_arn" {
  description = "Lambda実行ロールARN"
  value       = aws_iam_role.lambda_exec.arn
}

output "apigateway_api_id" {
  description = "API Gateway API ID"
  value       = aws_api_gateway_rest_api.this.id
}

output "apigateway_api_endpoint" {
  description = "API Gatewayエンドポイント"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "apigateway_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "apigateway_stage_name" {
  description = "API Gatewayステージ名"
  value       = aws_api_gateway_stage.this.stage_name
}

output "lambda_log_group_name" {
  description = "Lambda CloudWatch Logsグループ名"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "apigw_access_log_group_name" {
  description = "API Gatewayアクセスログ用CloudWatch Logsグループ名"
  value       = var.enable_apigw_access_logs ? aws_cloudwatch_log_group.apigw_access[0].name : null
}
