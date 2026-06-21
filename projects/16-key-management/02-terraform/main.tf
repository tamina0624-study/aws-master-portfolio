
# ================================
# ルート main.tf（人間向け目次・導線）
# ================================
# このディレクトリは環境定義・サービス定義の入口です。
#
# 【構成ファイル一覧】
#   - main.tf         : 目次・導線（module呼び出し例や構成概要のみ）
#   - vpc.tf          : VPC関連module呼び出し
#   - security_group.tf: セキュリティグループmodule呼び出し
#   - ec2.tf          : EC2 module呼び出し
#   - alb.tf          : ALB module呼び出し
#   - route53.tf      : Route53 module呼び出し
#   - waf.tf          : WAF module呼び出し
#   - variables.tf    : 変数定義
#   - outputs.tf      : 出力値定義
#   - providers.tf    : provider定義
#   - data.tf         : dataリソース
#
# 【注意事項】
# - module呼び出しは各tfファイルに分割
# - サービス定義・環境依存値はここで管理
# - 冗長でも明示的な記述を優先
#
# 【初見者向け導線】
# まずはこのmain.tfとREADME.mdを参照してください。

# ================================
# module呼び出し（引数なし、sourceのみ）
# ================================

module "vpc" {
  source         = "./modules/vpc"
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}


variable "environment" {
  description = "環境名"
  type        = string
  default     = "dev"
}

module "rds" {
  source = "./modules/rds"

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  db_subnet_group_name       = "analyze-research-db-subnet-group-private-v2"
  allowed_security_group_ids = [module.security_group.alb_sg_id]
  allowed_cidr_blocks        = []
}

module "dynamodb" {
  source = "./modules/dynamodb"

  table_name = "analyze-research-key-management-${var.environment}"
  hash_key   = "key_id"
  attributes = [
    {
      name = "key_id"
      type = "S"
    }
  ]

  point_in_time_recovery_enabled = true
  server_side_encryption_enabled = true
  tags = {
    Service = "dynamodb"
  }
}
