# projects/04-enterprise-landing-zone/remediation.tf

# 1. Lambda関数用のIAMロール（S3を操作する権限とログ出力権限）
resource "aws_iam_role" "remediation_lambda_role" {
  name = "${var.project_name}-remediation-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole", Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "remediation_lambda_policy" {
  name = "${var.project_name}-remediation-lambda-policy"
  role = aws_iam_role.remediation_lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow", Action = ["s3:PutBucketPublicAccessBlock"]
        Resource = "*"
      },
      {
        Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 2. 自動修復を行うLambda関数本体（PythonコードをTerraform内で直接定義してZip化）
data "archive_file" "remediation_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/remediation_lambda.zip"
  source {
    filename = "index.py"
    content  = <<-EOF
import boto3

s3 = boto3.client('s3')

def handler(event, context):
    # EventBridgeから渡されるCloudTrailのログ情報から、変更されたバケット名を抽出
    detail = event.get('detail', {})
    bucket_name = detail.get('requestParameters', {}).get('bucketName')
    
    if not bucket_name:
        return "No bucket name found."
        
    print(f"警告: {bucket_name} のパブリックアクセス設定が変更されました。自動修復を開始します。")
    
    # バケットのパブリックアクセスを強制的に「すべてブロック（True）」に戻す
    s3.put_public_access_block(
        Bucket=bucket_name,
        PublicAccessBlockConfiguration={
            'BlockPublicAcls': True,
            'IgnorePublicAcls': True,
            'BlockPublicPolicy': True,
            'RestrictPublicBuckets': True
        }
    )
    return f"修復完了: {bucket_name} を安全な状態に戻しました。"
EOF
  }
}

resource "aws_lambda_function" "s3_remediation" {
  filename         = data.archive_file.remediation_lambda_zip.output_path
  function_name    = "${var.project_name}-s3-auto-remediation"
  role             = aws_iam_role.remediation_lambda_role.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.remediation_lambda_zip.output_base64sha256
}

# 3. EventBridgeルール（S3のパブリック設定変更を検知するセンサー）
resource "aws_cloudwatch_event_rule" "s3_public_access_change" {
  name        = "${var.project_name}-s3-public-access-change"
  description = "S3バケットのパブリックアクセス設定が変更・削除されたことを検知します"
  
  # CloudTrail経由で「S3のパブリックアクセスブロックを外した（または変更した）」というAPIコールを監視
  event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "eventSource": ["s3.amazonaws.com"],
      "eventName": ["DeleteBucketPublicAccessBlock", "PutBucketPublicAccessBlock"]
    }
  })
}

# 4. EventBridge（センサー）とLambda（修復実行）を繋ぐ
resource "aws_cloudwatch_event_target" "trigger_remediation" {
  rule      = aws_cloudwatch_event_rule.s3_public_access_change.name
  target_id = "TriggerS3RemediationLambda"
  arn       = aws_lambda_function.s3_remediation.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_remediation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_public_access_change.arn
}
