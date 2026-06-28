# 15 Analyze & Research

---

> 「システムは動いているはずなのに、どこかおかしい。
> でも何を見れば問題箇所が分かるのか、何のツールを使えばいいのか分からない。」

> 「ネットワークの疎通確認をするのに、毎回 EC2 に SSH してコマンドを叩いている。
> もっとスマートに確認する方法があるはず。」

AWS には「何が起きているかを可視化する」「ネットワーク経路を分析する」「権限設定を確認する」ための専用サービスが多数あります。
**CloudWatch** によるメトリクス可視化、**VPC Reachability Analyzer** によるネットワーク疎通の自動分析、**IAM Access Analyzer** による権限設定の検証など、これらを使いこなすことで障害調査・設計レビューの精度と速度が大きく上がります。

本プロジェクトは、AWS の可視化・ネットワーク監視・セキュリティ権限分析ツールを調査・研究した成果です。

## 解説動画

[![YouTube](https://img.shields.io/badge/YouTube-解説動画①-FF0000?logo=youtube&logoColor=white)](https://youtu.be/kObeTGyUj7E?si=dldPAO69StnU4sNt)
[![YouTube](https://img.shields.io/badge/YouTube-解説動画②-FF0000?logo=youtube&logoColor=white)](https://youtu.be/0cOz1XHFGfI?si=rf_1plJo7rdthS6d)

---

## 学習テーマ

### 01-visiable-monitering（可視化・モニタリング）
- CloudWatch メトリクス・ダッシュボードによるリソース状態の可視化
- アラームと通知の設計

### 02-network-monitering-reachableanalize（ネットワーク監視・到達可能性分析）
- VPC Reachability Analyzer による疎通確認の自動化
- ネットワーク経路の可視化と問題の特定

### 03-security-authority（セキュリティ・権限分析）
- IAM Access Analyzer による権限設定の外部公開チェック
- 意図しないアクセス許可の検出

---

## ディレクトリ構成

```
15-analyze-research/
├── 01-visiable-monitering/          # 可視化・モニタリング
├── 02-network-monitering-reachableanalize/  # ネットワーク監視・到達可能性分析
└── 03-security-authority/           # セキュリティ・権限分析
```
