
# ================================
# VPC module main.tf（人間向け目次・導線）
# ================================
# このディレクトリはVPC関連のmoduleです。
#
# 【構成ファイル一覧】
#   - vpc.tf         : VPCリソース
#   - subnet.tf      : サブネット
#   - igw.tf         : インターネットゲートウェイ
#   - route_table.tf : ルートテーブル関連
#   - nacl.tf        : NACL関連
#   - endpoints.tf   : SSM Session Manager向けVPC Endpoint
#   - vpn_connection.tf : Customer Gateway と Transit Gateway の Site-to-Site VPN接続
#   - variables.tf   : 変数定義
#   - outputs.tf     : 出力値定義
#
# 【注意事項】
# - module内はpure module方針
# - 環境依存・サービス固有値は受け取るだけ
# - 冗長でも明示的な記述を優先
#
# 【初見者向け導線】
# まずはこのmain.tfとREADME.mdを参照してください。


module "vpc_aws_vpc1" {
  source         = "./aws_vpc1"
  providers = {
    aws = aws.tokyo
  }
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

module "vpc_aws_vpc2" {
  source         = "./aws_vpc2"
  providers = {
    aws = aws.tokyo
  }
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

module "vpc_as_onpremise" {
  source         = "./as_onpremise"
  providers = {
    aws       = aws
    aws.tokyo = aws.tokyo
  }
}
