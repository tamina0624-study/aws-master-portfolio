# Security Group Module

このディレクトリはSecurity Group関連のTerraform moduleです。

## ファイル構成
- main.tf      : 人間向け目次・導線（リソース定義なし）
- ec2_web_sg.tf: EC2用SG
- alb_sg.tf    : ALB用SG
- variables.tf : 変数定義
- outputs.tf   : 出力値定義

## 方針
- moduleはpure moduleとして設計
- 環境依存・サービス固有値は受け取るだけ
- 冗長でも明示的な記述を優先

## 注意事項
- 変更時は責務ごとにファイルを分割・整理してください
- 詳細はmain.tfコメントも参照
