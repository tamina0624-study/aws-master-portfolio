# EC2 Module

このディレクトリはEC2関連のTerraform集約moduleです。

## ファイル構成
- main.tf           : 人間向け目次・導線（集約module）
- common/           : 共通IAM(SSMロール/インスタンスプロファイル)
- aws_vpc1/         : aws_vpc1向けEC2サブmodule
- aws_vpc2/         : aws_vpc2向けEC2サブmodule
- as_onpremise/     : as_onpremise向けEC2サブmodule
- variables.tf      : 集約moduleの変数定義
- outputs.tf        : 集約moduleの出力値定義

## 方針
- moduleはpure moduleとして設計
- 環境依存・サービス固有値は受け取るだけ
- 冗長でも明示的な記述を優先

## 注意事項
- 変更時は責務ごとにファイルを分割・整理してください
- 詳細はmain.tfコメントも参照

## VPC定義からサブネットIDを引く使い方
`module.vpc` から受け取った `aws_vpc` オブジェクトの `id` を使い、
`ec2` モジュール内で `data.aws_subnets` により Nameタグ一致のサブネットIDを解決できます。

```hcl
module "ec2" {
	source = "./module/ec2"

	vpc_id_aws_vpc1        = module.vpc.aws_vpc1.id
	vpc_id_aws_vpc2        = module.vpc.aws_vpc2.id
	vpc_id_as_onpremise    = module.vpc.onpremise_vpc.id

	subnet_name_tag_aws_vpc1       = "public-subnet-1_aws_vpc1"
	subnet_name_tag_aws_vpc2       = "public-subnet-1_aws_vpc2"
	subnet_name_tag_as_onpremise   = "public-subnet-1_as_onpremise"

	security_group_id_aws_vpc1     = var.ec2_sg_id_aws_vpc1
	security_group_id_aws_vpc2     = var.ec2_sg_id_aws_vpc2
	security_group_id_as_onpremise = var.ec2_sg_id_as_onpremise
}
```
