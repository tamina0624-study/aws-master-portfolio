# lambda module variables

variable "function_name" {
  description = "Lambda関数名"
  type        = string
  default     = "analyze-research-handler"
}

variable "runtime" {
  description = "Lambdaランタイム"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Lambdaハンドラー"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "filename" {
  description = "デプロイするzipファイルのパス"
  type        = string
  default     = null
  nullable    = true
}

variable "source_code_hash" {
  description = "Lambdaソースコードハッシュ（更新検知用）"
  type        = string
  default     = null
  nullable    = true
}

variable "enable_powertools_layer" {
  description = "AWS Powertoolsレイヤーを自動付与するか"
  type        = bool
  default     = true
}

variable "layers" {
  description = "追加LambdaレイヤーARN一覧（enable_powertools_layer=false時に使用）"
  type        = list(string)
  default     = []
}

variable "powertools_layer_ssm_parameter_name" {
  description = "Powertools Layer ARNを取得するSSMパラメータ名"
  type        = string
  default     = "/aws/service/powertools/beta/python/x86_64/python3.12/latest"
}

variable "timeout" {
  description = "Lambdaタイムアウト（秒）"
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Lambdaメモリサイズ（MB）"
  type        = number
  default     = 128
}

variable "architectures" {
  description = "Lambdaアーキテクチャ"
  type        = list(string)
  default     = ["x86_64"]
}

variable "publish" {
  description = "新しいバージョンを発行するか"
  type        = bool
  default     = false
}

variable "lambda_tracing_mode" {
  description = "Lambda X-Ray tracing mode (PassThrough/Active)"
  type        = string
  default     = "Active"
}

variable "environment_variables" {
  description = "Lambda環境変数"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Lambdaを配置するサブネットID一覧"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Lambdaに割り当てるセキュリティグループID一覧"
  type        = list(string)
  default     = []
}

variable "api_name" {
  description = "API Gateway API名"
  type        = string
  default     = "analyze-research-http-api"
}

variable "api_protocol_type" {
  description = "API Gatewayプロトコル種別"
  type        = string
  default     = "HTTP"
}

variable "route_key" {
  description = "API Gatewayルートキー"
  type        = string
  default     = "ANY /{proxy+}"
}

variable "stage_name" {
  description = "API Gatewayステージ名"
  type        = string
  default     = "prod"
}

variable "auto_deploy" {
  description = "API Gatewayの自動デプロイ有効化"
  type        = bool
  default     = true
}

variable "detailed_metrics_enabled" {
  description = "ルート詳細メトリクスを有効化"
  type        = bool
  default     = false
}

variable "throttling_burst_limit" {
  description = "API Gatewayルートのバースト制限"
  type        = number
  default     = 100
}

variable "throttling_rate_limit" {
  description = "API Gatewayルートのレート制限"
  type        = number
  default     = 50
}

variable "apigw_logging_level" {
  description = "API Gatewayログレベル（OFF/ERROR/INFO）"
  type        = string
  default     = "OFF"
}

variable "enable_apigw_xray_tracing" {
  description = "API Gateway StageでX-Ray tracingを有効化するか"
  type        = bool
  default     = true
}

variable "cors_allow_origins" {
  description = "CORS許可オリジン"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "CORS許可メソッド"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  description = "CORS許可ヘッダー"
  type        = list(string)
  default     = ["content-type", "authorization", "x-amz-date", "x-api-key", "x-amz-security-token"]
}

variable "cors_expose_headers" {
  description = "CORS公開ヘッダー"
  type        = list(string)
  default     = []
}

variable "cors_max_age" {
  description = "CORS max-age（秒）"
  type        = number
  default     = 3600
}

variable "tags" {
  description = "タグ"
  type        = map(string)
  default     = { Environment = "dev" }
}

variable "lambda_log_retention_in_days" {
  description = "Lambdaロググループの保持日数"
  type        = number
  default     = 14
}

variable "enable_apigw_access_logs" {
  description = "API Gatewayアクセスログの出力を有効化するか"
  type        = bool
  default     = true
}

variable "apigw_access_log_retention_in_days" {
  description = "API Gatewayアクセスロググループの保持日数"
  type        = number
  default     = 14
}
