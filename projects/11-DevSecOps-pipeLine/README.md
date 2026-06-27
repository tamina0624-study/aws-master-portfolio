# 11 DevSecOps Pipeline

---

> 「リリース直前に脆弱性スキャンをしたら、深刻な問題が大量に出てきた。
> 直す時間もなく、リリースを延期するしかなかった。」

> 「アプリは動いているのに、Pod のリソース不足でじわじわとレスポンスが悪化していた。
> 気づいたのはユーザーからのクレームが来てから。」

セキュリティは「リリース前に一度チェックする」ものではなく、「開発の各ステップに組み込む」ものという考え方が **DevSecOps** です。
**Trivy** を CI に組み込むことで、コードをコミットした瞬間に脆弱性を検知でき（シフトレフト）、問題を早期に発見・修正できます。
さらに **EKS + Helm** でコンテナを効率的に管理し、**Prometheus + Grafana** で「システムが正常に動き続けているか」をリアルタイムに把握できる可観測性の基盤を持つことが、現代のクラウドネイティブ運用の標準形です。

本プロジェクトは、その DevSecOps の考え方を、コンテナビルドから EKS デプロイ・監視基盤まで一貫して実装した学習成果です。

## 解説動画

[![YouTube](https://img.shields.io/badge/YouTube-解説動画-FF0000?logo=youtube&logoColor=white)](https://youtu.be/WyBvxLbeksA?si=UdiLBa3QMc4sPzx3)

---

セキュリティ・スケーラビリティ・可観測性を軸に、コンテナアプリケーションから EKS 基盤まで一貫して自動化したエンタープライズ向け DevSecOps パイプライン。

---

## 全体アーキテクチャ

```
┌──────────────────────────────────────────────────────────────────┐
│                     GitHub Actions パイプライン                   │
│                                                                  │
│  PR / push                                                       │
│    │                                                             │
│    ▼                                                             │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────────────────┐   │
│  │  Build   │  │ Security Scan│  │        Push              │   │
│  │  React   │─▶│ Trivy        │─▶│  ECR (承認済みのみ)       │   │
│  │  Docker  │  │ (FS + Image) │  │                          │   │
│  └──────────┘  └──────────────┘  └─────────────┬────────────┘   │
│                                                 │                │
│                                                 ▼                │
│                                        ┌──────────────────┐     │
│                                        │  Deploy (Helm)   │     │
│                                        │  EKS Rolling     │     │
│                                        │  Update          │     │
│                                        └──────────────────┘     │
└──────────────────────────────────────────────────────────────────┘
                                                 │
                              ┌──────────────────▼──────────────────┐
                              │        Amazon EKS                   │
                              │                                     │
                              │  ┌──────────┐  ┌─────────────────┐ │
                              │  │  React   │  │  IRSA           │ │
                              │  │  App Pod │  │ (Pod 単位の      │ │
                              │  │  (Helm)  │  │  最小権限)       │ │
                              │  └──────────┘  └─────────────────┘ │
                              │                                     │
                              │  ┌─────────────────────────────┐   │
                              │  │  Prometheus + Grafana        │   │
                              │  │  (kube-prometheus-stack)     │   │
                              │  │  Pod リソース使用率を可視化  │   │
                              │  └─────────────────────────────┘   │
                              └─────────────────────────────────────┘
```

---

## 実装フェーズ

### フェーズ 1: コンテナ戦略（React + Docker）
- `node:alpine` ベースのマルチステージビルド
- 攻撃表面を最小限に抑えた軽量イメージ

### フェーズ 2: Infrastructure as Code（Terraform + EKS）
- Terraform で Amazon EKS クラスターを定義
- マネージド型ノードグループで運用負荷を軽減
- **IRSA（IAM Roles for Service Accounts）** で Pod 単位に最小権限を適用

### フェーズ 3: DevSecOps パイプライン（GitHub Actions）
- Trivy によるシフトレフトセキュリティスキャン（FS + イメージ）
- 脆弱性が検知された場合は ECR へのプッシュをブロック
- 承認済みイメージのみ Helm でデプロイ

### フェーズ 4: Kubernetes 管理（Helm）
- K8s マニフェストを Helm Chart 化
- 環境（検証・本番）ごとの変数を values.yaml で管理
- ローリングアップデートによる無停止デプロイ

### フェーズ 5: 可観測性（Prometheus + Grafana）
- `kube-prometheus-stack` で監視基盤を構築
- Pod ごとの CPU・メモリ使用率をダッシュボードで可視化

---

## ファイル構成

```
11-DevSecOps-pipeLine/
├── .github/workflows/    # GitHub Actions パイプライン定義
├── app/                  # React フロントエンド
├── helm/                 # Helm Chart（Deployment / Service / Ingress）
├── terraform/            # EKS クラスター IaC
│   └── modules/          # VPC / EKS / IAM
├── monitoring/           # Prometheus + Grafana 設定
├── 00-overview/          # 概要・設計方針
├── 01-spec/              # 仕様書
├── 02-basic-design/      # 基本設計
├── 03-detail-design/     # 詳細設計
└── 学習結果.md           # 学習成果・設計思想のまとめ
```

---

## 設計のポイント

| 観点 | 実装内容 |
|------|---------|
| セキュリティ | Trivy でビルド段階に脆弱性を検知（シフトレフト）|
| 最小権限 | IRSA で Pod 単位の IAM ロールを分離 |
| 運用効率 | Helm Chart で環境差分を吸収 |
| 可観測性 | Prometheus + Grafana で継続監視 |

---

## 技術スタック

- **CI/CD**: GitHub Actions
- **コンテナ**: Docker (node:alpine マルチステージ)
- **コンテナリポジトリ**: Amazon ECR
- **オーケストレーション**: Amazon EKS, Helm
- **セキュリティ**: Trivy (シフトレフト)
- **IaC**: Terraform
- **監視**: Prometheus, Grafana (kube-prometheus-stack)
