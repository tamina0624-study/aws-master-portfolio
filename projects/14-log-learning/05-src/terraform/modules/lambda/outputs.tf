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
  value       = aws_apigatewayv2_api.this.id
}

output "apigateway_api_endpoint" {
  description = "API Gatewayエンドポイント"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "apigateway_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "apigateway_stage_name" {
  description = "API Gatewayステージ名"
  value       = aws_apigatewayv2_stage.this.name
}
