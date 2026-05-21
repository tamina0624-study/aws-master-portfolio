# 01 Basic Infrastructure

## 概要
AWSの基本的なインフラ（VPC, サブネット, EC2, S3など）をTerraformで構築するサンプルです。

## 特徴
- AWSリソースのIaC化（Infrastructure as Code）
- モジュール分割による再利用性
- セキュリティベストプラクティスを意識

## ディレクトリ構成
- main.tf … メイン設定
- variables.tf … 変数定義
- outputs.tf … 出力値
- modules/ … 各種モジュール

## 実行方法
```bash
terraform init
terraform plan
terraform apply
```

---
