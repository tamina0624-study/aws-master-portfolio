
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
	source = "./modules/vpc"
}

module "security_group" {
	source = "./modules/security_group"
	vpc_id = module.vpc.vpc_id
}

module "ec2" {
	source = "./modules/ec2"
	subnet_id = module.vpc.public_subnet_1_id
	security_group_id = module.security_group.ec2_web_sg_id
}

module "alb" {
	source = "./modules/alb"
	alb_sg_id = module.security_group.alb_sg_id
	subnet_1_ids = module.vpc.public_subnet_1_id
	subnet_2_ids = module.vpc.public_subnet_2_id
	vpc_id = module.vpc.vpc_id
	target_instance_id = module.ec2.instance_id
}

module "route53" {
	source = "./modules/route53"
	zone_name      = "xxxxx.test.example.com" # ←適宜修正
	alb_dns_name   = module.alb.alb_dns_name
	alb_zone_id    = module.alb.alb_zone_id
}

module "waf" {
	source = "./modules/waf"
	alb_arn = module.alb.alb_arn
}
