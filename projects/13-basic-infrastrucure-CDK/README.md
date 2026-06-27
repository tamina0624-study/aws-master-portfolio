# 13 Basic Infrastructure (AWS CDK)

01-basic-infrastructure で Terraform を使って構築した基本 AWS インフラを、AWS CDK (TypeScript) で再実装したプロジェクト。
「インフラをプログラミング言語で記述する」CDK の概念を実際に動かして習得した。

---

## 構成概要

```
┌─────────────────────────────────────────────────────┐
│               AWS CDK (TypeScript)                  │
│                                                     │
│  bin/ エントリーポイント                             │
│    └─ lib/ スタック定義 (TypeScript)                 │
│           │ cdk synth                               │
│           ▼                                         │
│       CloudFormation テンプレート                   │
│           │ cdk deploy                              │
│           ▼                                         │
│  ┌──────────────────────────────────────────────┐   │
│  │              AWS                             │   │
│  │  VPC                                        │   │
│  │  ├── パブリックサブネット                    │   │
│  │  │     └── EC2 (Security Group付き)          │   │
│  │  └── プライベートサブネット                  │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## Terraform との違い

| 観点 | Terraform | AWS CDK |
|------|-----------|---------|
| 記述言語 | HCL（独自DSL）| TypeScript / Python 等 |
| 型チェック | なし | あり（コンパイル時に検出）|
| 抽象度 | リソース単位 | Construct による高レベル抽象化 |
| 出力 | tfstate | CloudFormation テンプレート |
| AWS との親和性 | プロバイダー経由 | AWS 公式ライブラリ |

---

## ファイル構成

```
13-basic-infrastrucure-CDK/
├── bin/
│   └── 13-basic-infrastrucure-cdk.ts  # エントリーポイント
├── lib/
│   └── 13-basic-infrastrucure-cdk-stack.ts  # リソース定義（編集対象）
├── test/
│   └── *.test.ts                       # Jest ユニットテスト
├── cdk.json                            # CDK 設定
├── tsconfig.json                       # TypeScript 設定
├── package.json
└── 構成.md                             # フォルダ構成の解説
```

---

## 実行方法

```bash
# 依存パッケージインストール
npm install aws-cdk-lib constructs

# TypeScript ビルド
npm run build

# CloudFormation テンプレート生成（構文確認）
npx cdk synth

# 初回のみ：CDK 用リソースをブートストラップ
npx cdk bootstrap

# EC2 用キーペア作成（初回のみ）
aws ec2 create-key-pair --key-name portfolio-key \
  --query 'KeyMaterial' --output text > securet/portfolio-key.pem

# デプロイ
npx cdk deploy

# 差分確認
npx cdk diff

# ユニットテスト
npm run test
```

---

## デプロイ時に解決したエラー

| エラー | 原因 | 対処 |
|-------|------|------|
| `Cannot find module` | node_modules の不整合 | node_modules / package-lock.json 削除後 npm install |
| `SSM parameter /cdk-bootstrap/... not found` | ブートストラップ未実施 | `npx cdk bootstrap` を実行 |
| `key pair 'portfolio-key' does not exist` | キーペア未作成 | `aws ec2 create-key-pair` で事前に作成 |

---

## 技術スタック

- **IaC**: AWS CDK (TypeScript)
- **言語**: TypeScript
- **出力**: AWS CloudFormation
- **テスト**: Jest
- **AWS**: VPC, EC2, Security Group
