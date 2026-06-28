# WAF Module

このディレクトリはWAF関連のTerraform moduleです。

## ファイル構成
- main.tf               : 人間向け目次・導線（リソース定義なし）
- web_acl.tf            : WebACLリソース
- web_acl_association.tf: WebACLとALBの関連付け
- variables.tf          : 変数定義
- outputs.tf            : 出力値定義

## 方針
- moduleはpure moduleとして設計
- 環境依存・サービス固有値は受け取るだけ
- 冗長でも明示的な記述を優先

## 注意事項
- 変更時は責務ごとにファイルを分割・整理してください
- 詳細はmain.tfコメントも参照
