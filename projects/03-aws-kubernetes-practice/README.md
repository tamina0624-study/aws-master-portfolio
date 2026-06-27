# 03 AWS Kubernetes Practice

---

> 「Kubernetes の仕組みは分かってきたけど、
> AWS で本番相当の環境を作ろうとするとクラスターの構築が大変で、
> バージョンアップや Node 管理に追われてしまう。」

> 「ELB・IAM・ECR など AWS サービスと Kubernetes をどう連携させるか分からない。」

**Amazon EKS（Elastic Kubernetes Service）** を使えば、Kubernetes コントロールプレーンの運用を AWS に任せられます。
Node のスケーリング・バージョン管理・高可用性を AWS がマネージドで担ってくれるため、アプリケーション・セキュリティ・運用設計に集中できます。
Terraform と組み合わせることで、EKS クラスターから IAM・ネットワーク設定まで一括でコード化でき、環境の再現性が保てます。

本プロジェクトは、EKS を中心に AWS サービスと Kubernetes を連携させた実践的な構成を Terraform で構築した学習成果です。

---

## 概要
AWS上でKubernetes（EKS等）を活用した実践的な構成例・演習をまとめています。

## 特徴
- AWSリソースとKubernetesの連携
- IaCによるクラウド環境の自動構築
- アーキテクチャ図や運用ノウハウも記載

## ディレクトリ構成
- architecture.html … 構成図
- terraform/ … IaCコード

---
