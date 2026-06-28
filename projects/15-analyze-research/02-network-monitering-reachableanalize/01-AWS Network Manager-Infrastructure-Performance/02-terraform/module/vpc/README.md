# VPC Module

このディレクトリはVPC関連のTerraform moduleです。

## ファイル構成
- main.tf         : 人間向け目次・導線（リソース定義なし）
- vpc.tf          : VPCリソース
- subnet.tf       : サブネット
- igw.tf          : インターネットゲートウェイ
- route_table.tf  : ルートテーブル関連
- nacl.tf         : NACL関連
- endpoints.tf    : SSM Session Manager向けVPC Endpoint
- vpn_connection.tf : Customer Gateway と Transit Gateway の Site-to-Site VPN接続
- variables.tf    : 変数定義
- outputs.tf      : 出力値定義

## 方針
- moduleはpure moduleとして設計
- 環境依存・サービス固有値は受け取るだけ
- 冗長でも明示的な記述を優先

## 注意事項
- 変更時は責務ごとにファイルを分割・整理してください
- 詳細はmain.tfコメントも参照
