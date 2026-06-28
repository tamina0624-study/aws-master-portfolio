# 環境・サービス定義ディレクトリ

このディレクトリは、各種AWSサービスの環境定義・サービス定義を行うTerraform構成の入口です。

## ファイル構成
- main.tf         : 人間向け目次・導線（module呼び出し例や構成概要のみ）
- vpc.tf          : VPC module呼び出し
- security_group.tf: セキュリティグループmodule呼び出し
- ec2.tf          : EC2 module呼び出し
- alb.tf          : ALB module呼び出し
- route53.tf      : Route53 module呼び出し
- waf.tf          : WAF module呼び出し
- variables.tf    : 変数定義
- outputs.tf      : 出力値定義
- providers.tf    : provider定義
- data.tf         : dataリソース

## 方針
- module呼び出しは各tfファイルに分割
- サービス定義・環境依存値はここで管理
- 冗長でも明示的な記述を優先

## 注意事項
- 変更時は責務ごとにファイルを分割・整理してください
- 詳細はmain.tfコメントも参照
