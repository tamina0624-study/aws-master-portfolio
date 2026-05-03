# --- 1. スコープとポートを限定した Config ルール ---
resource "aws_config_config_rule" "sg_port_check_restricted" {
  name = "restricted-port-3820-check"


  source {
    owner             = "AWS"
    source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
  }

scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }

  # ポート 3820 を禁止ポートとして指定
  input_parameters = jsonencode({
    "blockedPort1" = "3820"
  })
}

# --- 1. 独自の修復用 SSM ドキュメントを定義 ---
resource "aws_ssm_document" "revoke_sg_3820" {
  name          = "Custom-RevokeSecurityGroup3820"
  document_type = "Automation"
  content = jsonencode({
    schemaVersion = "0.3"
    assumeRole    = "{{AutomationAssumeRole}}"
    parameters = {
      GroupId = { type = "String" }
      AutomationAssumeRole = { type = "String" }
    }
    mainSteps = [
      {
        name   = "revokeIngress"
        action = "aws:executeAwsApi"
        inputs = {
          Service    = "ec2"
          Api        = "RevokeSecurityGroupIngress"
          GroupId    = "{{GroupId}}"
          IpPermissions = [
            {
              IpProtocol = "tcp"
              FromPort   = 3820
              ToPort     = 3820
              IpRanges   = [{ CidrIp = "0.0.0.0/0" }]
            }
          ]
        }
      }
    ]
  })
}


# --- 2. 自動修復（Remediation）の設定 ---
resource "aws_config_remediation_configuration" "sg_remediation" {
  config_rule_name = aws_config_config_rule.sg_port_check_restricted.name
  resource_type    = "AWS::EC2::SecurityGroup"
  target_type      = "SSM_DOCUMENT"

# 正確なドキュメント名に変更
  target_id        = aws_ssm_document.revoke_sg_3820.name

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.remediation_role.arn
  }

  parameter {
    name           = "GroupId"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60
}

# 1. SSM Automationがこのロールを引き受けるための信頼関係
resource "aws_iam_role" "remediation_role" {
  name = "ConfigRemediationRole-SG"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      }
    ]
  })
}

# 2. セキュリティグループのルールを削除するためのポリシー
resource "aws_iam_role_policy" "remediation_policy" {
  name = "ConfigRemediationPolicy-SG"
  role = aws_iam_role.remediation_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DescribeSecurityGroups",
          "ssm:StartAutomationExecution"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}


# --- 1. 記録したログを保存するS3バケット ---
resource "aws_s3_bucket" "config_bucket" {
  bucket_prefix = "config-logs-portfolio-"
  force_destroy = true
}

# --- 2. AWS Config レコーダーの設定 ---
resource "aws_config_configuration_recorder" "main" {
  name     = "main-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

# --- 3. レコーダーの起動（ステータス） ---
resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.main]
}

# --- 4. 配信チャンネルの設定 ---
resource "aws_config_delivery_channel" "main" {
  name           = "main-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  depends_on     = [aws_config_configuration_recorder.main]
}

# --- 5. Config用IAMロール (まだ追加していない場合) ---
resource "aws_iam_role" "config_role" {
  name = "AWSConfigRole-Portfolio"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "config.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}


resource "aws_s3_bucket_policy" "config_logging_policy" {
  bucket = aws_s3_bucket.config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# アカウントIDを取得するためのデータソース（ファイルの冒頭などに置いてください）
data "aws_caller_identity" "current" {}
