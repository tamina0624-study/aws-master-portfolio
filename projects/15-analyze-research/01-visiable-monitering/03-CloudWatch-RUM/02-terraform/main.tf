
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
  source                                  = "./modules/security_group"
  vpc_id                                  = module.vpc.vpc_id
  ec2_web_https_source_security_group_ids = [module.vpc.ssm_endpoint_security_group_id]
}


variable "environment" {
  description = "環境名"
  type        = string
  default     = "dev"
}


module "lambda" {
  source = "./modules/lambda"

  subnet_ids         = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  security_group_ids = [aws_security_group.lambda.id]

  environment_variables = {
    DB_HOST     = module.rds.db_instance_address
    DB_PORT     = tostring(module.rds.db_instance_port)
    DB_USER     = local.rds_master_secret.username
    DB_PASSWORD = local.rds_master_secret.password
  }
}

module "rds" {
  source = "./modules/rds"

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  db_subnet_group_name       = "analyze-research-db-subnet-group-private"
  allowed_security_group_ids = [aws_security_group.lambda.id]
  allowed_cidr_blocks        = []
}

module "ec2" {
  source            = "./modules/ec2"
  subnet_id         = module.vpc.private_subnet_1_id
  security_group_id = module.security_group.ec2_web_sg_id
}

module "alb" {
  source                      = "./modules/alb"
  alb_sg_id                   = module.security_group.alb_sg_id
  subnet_1_ids                = module.vpc.public_subnet_1_id
  subnet_2_ids                = module.vpc.public_subnet_2_id
  vpc_id                      = module.vpc.vpc_id
  target_instance_id          = module.ec2.instance_id
  alb_access_logs_enabled     = true
  alb_access_logs_bucket      = "analyze-research-alb"
  alb_access_logs_prefix      = ""
  alb_connection_logs_enabled = true
  alb_connection_logs_bucket  = "analyze-research-alb"
  alb_connection_logs_prefix  = ""
}
