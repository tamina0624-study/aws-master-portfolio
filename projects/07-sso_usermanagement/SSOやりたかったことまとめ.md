# SSOやりたかったことまとめ

## 登場するAWSの主な機能・リソース
- AWS Organizations（組織管理・マルチアカウント統制）
- AWS IAM Identity Center（旧SSO）
    - ユーザー（Identity Center Directory内のID）
    - グループ（ユーザーをまとめる単位）
    - Permission Set（AWSリソースへの権限テンプレート）
    - Account Assignment（ユーザー/グループとPermission Setの割り当て）
- AWSアカウント（リソース実体が存在する単位）
- Terraform（AWSリソースのIaC自動化ツール）

## 各機能・リソースの関係性
- Organizations：マルチアカウント環境の統制基盤。Identity Centerやアカウントの親となる。
- IAM Identity Center：ユーザー・グループ・Permission Setを管理し、AWSアカウントへのアクセス権限を一元管理。
- Permission Set：AWSリソースへのアクセス権限（ロール）をテンプレート化し、ユーザーやグループに割り当てる。
- Account Assignment：ユーザー/グループとPermission Setを、特定のAWSアカウントに紐付ける。
- Terraform：これらのリソースをコードで一元管理・自動化するためのツール。

## 今回何が出来なかったのか
- AWS Organizationsの管理権限がなかったため、
    - SSO（IAM Identity Center）のPermission SetやAccount AssignmentをTerraformで自動化できなかった
    - SSOユーザー・グループの作成はできたが、権限割り当てができず、SSOログインしても何も操作できなかった
- 本来やりたかった「エンタープライズ基準のSSO権限管理の自動化」は未達成
- ただし、ユーザー・グループ管理や運用台帳の整備、将来の自動化設計準備は進めることができた

---

この経験を活かし、今後Organizations権限が得られた際は、設計・自動化をすぐに実践できるよう準備しておく。
