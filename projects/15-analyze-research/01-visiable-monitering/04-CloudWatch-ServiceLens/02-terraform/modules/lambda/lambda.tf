# Lambda実行ロールの信頼ポリシー
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.function_name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.function_name}-exec-role"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_xray_write_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda_function_payload.zip"
}

data "aws_ssm_parameter" "powertools_layer_arn" {
  count = var.enable_powertools_layer ? 1 : 0
  name  = var.powertools_layer_ssm_parameter_name
}

locals {
  lambda_filename         = var.filename != null ? var.filename : data.archive_file.lambda_package.output_path
  lambda_source_code_hash = var.source_code_hash != null ? var.source_code_hash : data.archive_file.lambda_package.output_base64sha256
  lambda_layers           = var.enable_powertools_layer ? [data.aws_ssm_parameter.powertools_layer_arn[0].value] : var.layers
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  runtime       = var.runtime
  handler       = var.handler

  filename         = local.lambda_filename
  source_code_hash = local.lambda_source_code_hash
  layers           = local.lambda_layers

  timeout       = var.timeout
  memory_size   = var.memory_size
  architectures = var.architectures
  publish       = var.publish

  environment {
    variables = merge(
      {
        POWERTOOLS_SERVICE_NAME = var.function_name
        POWERTOOLS_LOG_LEVEL    = "INFO"
      },
      var.environment_variables
    )
  }

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 && length(var.security_group_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tracing_config {
    mode = var.lambda_tracing_mode
  }

  tags = merge(var.tags, {
    Name = var.function_name
  })

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_vpc_access_execution,
    aws_iam_role_policy_attachment.lambda_xray_write_access,
    aws_cloudwatch_log_group.lambda
  ]
}
