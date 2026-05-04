# Security Group Module

このモジュールは、柔軟なingress/egressルールを持つセキュリティグループを作成します。

## 変数
- name: セキュリティグループ名
- description: 説明
- vpc_id: VPCのID
- ingress_rules: インバウンドルール（リスト）
- egress_rules: アウトバウンドルール（リスト）
- tags: タグ

## 出力
- security_group_id: 作成されたセキュリティグループのID
