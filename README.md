# ![ポートフォリオ全体イメージ](Top.png)
# AWS Master Portfolio

AWS インフラ設計・IaC・セキュリティ自動化・CI/CD・コンテナ運用を一連で学習し、成果物としてまとめたポートフォリオです。
実際の業務課題を想定し、設計・構築・自動化・運用まで一貫して取り組んでいます。

---

## 技術スタック

| 領域 | 使用技術 |
|------|---------|
| IaC | Terraform, AWS CDK (TypeScript) |
| コンテナ / オーケストレーション | Docker, Kubernetes (EKS), Helm |
| CI/CD | GitHub Actions, ECR, ECS Fargate |
| セキュリティ | GuardDuty, WAF v2, KMS, IAM, Trivy, CodeQL, gitleaks |
| 監視 / ログ | CloudWatch, Prometheus, Grafana, CloudTrail, Athena |
| ネットワーク | VPC, Site-to-Site VPN, BGP, strongSwan |
| 認証 / 認可 | IAM Identity Center (SSO), OIDC, Permissions Boundary, IRSA |
| 言語 | Python (Flask), TypeScript, HCL |

---

## プロジェクト一覧

### インフラ基礎

| プロジェクト | 内容 |
|------------|------|
| [01-basic-infrastructure](projects/01-basic-infrastructure/) | VPC・EC2・S3 を Terraform モジュールで構築 |
| [13-basic-infrastrucure-CDK](projects/13-basic-infrastrucure-CDK/) | 同構成を AWS CDK (TypeScript) で再実装 |

### Kubernetes

| プロジェクト | 内容 |
|------------|------|
| [02-kubernetes-basic](projects/02-kubernetes-basic/) | Pod / Service / Deployment の基礎マニフェスト |
| [03-aws-kubernetes-practice](projects/03-aws-kubernetes-practice/) | EKS を使った AWS 上での実践構成 |

### セキュリティ・ガバナンス

| プロジェクト | 内容 |
|------------|------|
| [04-enterprise-landing-zone](projects/04-enterprise-landing-zone/) | CloudTrail・KMS・IAM Permissions Boundary・自動修復 Lambda によるセキュリティ基盤 |
| [06-security](projects/06-security/) | GuardDuty → EventBridge → Lambda → WAF 自動 IP ブロック |
| [07-sso_usermanagement](projects/07-sso_usermanagement/) | IAM Identity Center による SSO・権限ライフサイクル管理 |
| [09-secret-upload-prevention](projects/09-secret-upload-prevention/) | .gitignore / secret フォルダ / pre-commit フックによる機密情報漏えい防止 |
| [16-key-management](projects/16-key-management/) | KMS・Parameter Store・Secrets Manager の使い分けと暗号化・監査設計 |

### ネットワーク

| プロジェクト | 内容 |
|------------|------|
| [05-hybrid-network](projects/05-hybrid-network/) | Site-to-Site VPN + BGP によるハイブリッドネットワーク（EC2 で模擬）|
| [10-Hybrid-Cloud-Connectivity-and-Security-Automation](projects/10-Hybrid-Cloud-Connectivity-and-Security-Automation/) | VPN + GuardDuty + WAF + Lambda を組み合わせた統合ハイブリッドセキュリティ構成 |

### 監視 / ログ

| プロジェクト | 内容 |
|------------|------|
| [08-alratConstruct](projects/08-alratConstruct/) | CloudWatch + SNS + Lambda によるアラート設計と通知整形 |
| [14-log-leaning](projects/14-log-leaning/) | AWS 全サービスのログ設計・Athena 分析・CloudWatch Insights・QuickSight 可視化 |
| [15-analyze-reseach](projects/15-analyze-reseach/) | 可視化・ネットワーク監視・セキュリティ権限の調査・分析 |

### CI/CD・DevSecOps

| プロジェクト | 内容 |
|------------|------|
| [11-DevSecOps-pipeLine](projects/11-DevSecOps-pipeLine/) | EKS + Helm + Trivy + Prometheus/Grafana による DevSecOps パイプライン |
| [17-cicd-pippeline](projects/17-cicd-pippeline/) | Python + Docker + Terraform を対象に GitHub Actions で構築した CI/CD（OIDC・多層セキュリティスキャン・段階的デプロイ）|

### アプリケーション / ツール

| プロジェクト | 内容 |
|------------|------|
| [12-mask-app](projects/12-mask-app/) | テキスト内の機密情報を自動検出・マスキングする React / Vanilla JS ツール |

---

## ポートフォリオの特徴

- 学習ごとに設計思想・トラブルシュート・得た知見をドキュメント化
- Terraform・CDK によるインフラのコード化を一貫して実践
- セキュリティをコード・コンテナ・IaC・ランタイムの複数レイヤーで設計
- CI/CD は OIDC・多層スキャン・段階承認まで本番相当の設計で実装
