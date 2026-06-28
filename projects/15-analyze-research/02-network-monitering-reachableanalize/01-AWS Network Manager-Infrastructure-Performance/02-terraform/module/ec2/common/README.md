# EC2 Common IAM Module

このディレクトリは、EC2にアタッチする共通IAMロール/インスタンスプロファイルを管理するTerraform submoduleです。

## 管理対象
- Session Manager用IAMロール
- Session Manager用IAMインスタンスプロファイル

## 方針
- 複数環境(aws_vpc1/aws_vpc2/as_onpremise)で同じIAMを再利用
- IAM定義を1箇所に集約して重複を避ける
