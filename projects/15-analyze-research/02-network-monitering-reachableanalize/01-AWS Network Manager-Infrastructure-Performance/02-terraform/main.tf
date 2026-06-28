
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
  source         = "./module/vpc"
  providers = {
    aws       = aws
    aws.tokyo = aws.tokyo
  }
}

module "ec2" {
  source         = "./module/ec2"
  providers = {
    aws       = aws
    aws.tokyo = aws.tokyo
  }
  vpc = module.vpc
}
