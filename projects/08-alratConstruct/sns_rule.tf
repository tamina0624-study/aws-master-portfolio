
# Lambda関数（アラートメッセージ整形用）
resource "aws_lambda_function" "alert_formatter" {
  filename         = "alert_formatter.zip" # デプロイ用zip
  function_name    = "alert-formatter"
  handler          = "alert_formatter.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("alert_formatter.zip")
}

# Lambda実行ロール
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# SNSサブスクリプション（High/Low両方のトピックにLambdaを紐付け）
resource "aws_sns_topic_subscription" "high_alert_lambda" {
  topic_arn = aws_sns_topic.high_alert.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alert_formatter.arn
}

resource "aws_sns_topic_subscription" "low_alert_lambda" {
  topic_arn = aws_sns_topic.low_alert.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alert_formatter.arn
}

# LambdaにSNSからのInvoke権限を付与
resource "aws_lambda_permission" "allow_sns_high" {
  statement_id  = "AllowExecutionFromSNSHigh"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert_formatter.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.high_alert.arn
}

resource "aws_lambda_permission" "allow_sns_low" {
  statement_id  = "AllowExecutionFromSNSLow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert_formatter.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.low_alert.arn
}
