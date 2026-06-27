# 14-log-leaning

---

> 「本番で障害が起きた。原因を調べようとしたら、
> ログがどこにあるか分からない。CloudWatch？S3？そもそも出力設定してたっけ？
> 原因特定に 3 時間かかってしまった。」

> 「ログは取っているのに、量が多すぎて何を見ればいいか分からない。
> 結局、目視で grep するだけになってしまっている。」

ログは「出す」だけでは意味がありません。「どこへ出すか」「どう検索するか」「何を可視化するか」まで設計して初めて障害調査やコスト分析に活かせます。
**CloudTrail・VPC Flow Logs・ALB アクセスログ** など AWS 各サービスのログ出力先を整理し、**CloudWatch Logs Insights** や **Athena** でクエリ検索、**QuickSight** でダッシュボード化する一連の流れを理解すると、「ゲートウェイ→ALB→アプリ→DB」という経路でログをたどって障害箇所を素早く切り分けられるようになります。

本プロジェクトは、その AWS ログ運用の全体像を、設計から Terraform 実装・CLI 検証・可視化まで一貫して学んだ成果です。

## 解説動画

[![YouTube](https://img.shields.io/badge/YouTube-解説動画①-FF0000?logo=youtube&logoColor=white)](https://youtu.be/D0yq7RBA7Y4?si=ZFfNWKRONoC8y8JT)
[![YouTube](https://img.shields.io/badge/YouTube-解説動画②-FF0000?logo=youtube&logoColor=white)](https://youtu.be/pcL7G5zZGWQ?si=6cOjcKHaYTRE0asG)
[![YouTube](https://img.shields.io/badge/YouTube-解説動画③-FF0000?logo=youtube&logoColor=white)](https://youtu.be/yZLg4nFTc0Y?si=ATEopEeO5r91c8X0)

---

AWSにおけるログ設計・収集・分析・可視化・運用を一通り学ぶための学習フォルダです。
CloudTrail、CloudWatch Logs、S3アクセスログ、VPC Flow Logs、ALB/ELBログ、RDSログ、Lambdaログ、API Gatewayログ、Route53ログ、WAF関連ログなどを対象に、
「どこに出るか」「どう見るか」「障害調査や運用改善にどう使うか」を整理しています。

## このフォルダで学んでいること

- AWSの各サービスがどこへログを出力するかの整理
- CloudWatch Logs Insights、Athena、QuickSightを使ったログ分析と可視化
- 障害調査でログをどうたどるかという運用視点の整理
- 保存期間、暗号化、アクセス制御、マスキング、コスト最適化などの設計観点
- Terraformで学習用インフラを構築し、ログ取得と確認ができる状態まで持っていく流れ

## 学習対象の主なサービス

- CloudTrail
- CloudWatch Logs
- S3 Access Logs
- VPC Flow Logs
- ALB / ELB Access Logs
- RDS Logs
- Lambda Logs
- API Gateway Access Logs / Execution Logs
- Route53 Query Logs
- WAF Logs
- VPC Endpoint Logs
- EC2 CloudWatch Agent Logs
- SQS DLQ など周辺の監視・調査用ログ

## 学習の進め方

このフォルダでは、以下の流れでログ学習を進めています。

1. 対象サービスを作成する
2. 各サービスのログ出力先を設定する
3. 実際のログフォーマットを確認する
4. AthenaやCloudWatch Logs Insightsで検索・分析する
5. QuickSightやダッシュボードで可視化する
6. 障害や異常系を想定して、どのログで原因特定できるかを確認する

## ディレクトリ構成

### 01-reshearch

調査メモと整理資料です。

- awsログ運用まとめ.md
	- ログ種別、可視化手段、トラブル調査手順、運用観点を整理
- awsログ取得先一覧表.md
	- 各ログがCloudWatchとS3のどちらへ出せるかを一覧化
- awsログ管理ベストプラクティス.md
	- 保存、暗号化、権限制御、統合管理などの基本方針を整理
- awsログ障害調査活用一覧表.md
	- 障害調査でどのログを使うかを整理
- awsログCLI_PowerShell活用例.md
	- CLIやPowerShellでログを確認する実践例を記録

### 02-spec

学習の観点と設計時の考慮事項をまとめた資料です。

- awsログ学習フロー.md
	- 学習を進める順序を実践ベースで定義
- awsログ管理_設計ポイント.md
	- 命名規則、保持期間、暗号化、改ざん対策、法令対応などの設計観点を整理

### 03-design

基本設計と詳細設計を格納しています。

- 01-basic-design
	- 学習対象サービス一覧、命名ルール例、基本設計書を配置
- 02-detailed-design
	- VPC、S3、EC2、ALB、Route53、WAF、Lambda、RDS、API Gatewayなどのパラメータ定義を配置

ログ基盤そのものだけでなく、ログを発生・中継・蓄積・参照する周辺AWSサービスまで含めて設計しているのが特徴です。

### 04-cli

AWS CLI / PowerShellでの確認コマンド集です。

- VPC Flow Logsの確認コマンド
- S3バケット作成手順
- 実環境のログ設定を手早く検証するためのコマンド例

GUIだけでなくCLIでも状態確認できるようにしておくことで、障害切り分けを速くする意図があります。

### 05-src

Terraformで学習環境を管理するソースです。

- terraform/main.tf
	- VPC、Security Group、S3、EC2、ALB、Route53、WAF、Lambda、RDSを呼び出すルート構成
- terraform/modules
	- 各サービスをモジュール化して管理
- 現物合わせ作業記録.md
	- 実環境との差分修正、ALBログ設定、S3設定、State同期などの作業内容を記録

特に以下の学びが大きいです。

- ログ保存先のS3設定や暗号化設定の扱い
- ALBアクセスログ / コネクションログをTerraformへ反映する方法
- 既存環境とTerraform定義のドリフトを解消する流れ
- ログ確認用の周辺リソースも含めてIaC管理する重要性

### 06-output

日別の学習結果・確認結果を残した出力フォルダです。

- 20260530.md
	- VPC Flow Logsのフォーマット確認、Athena分析、QuickSight可視化
- 20260605.md
	- RDS、Lambda、API Gateway、ELBログの確認と、メトリクス監視の活用整理
- 20260606.md
	- 各種ログの確認結果、ログの出力先、ログ活用による障害調査・コスト把握・利用分析の整理

## この学習で得た理解

- ログは「出す」だけでなく、「保存先」「検索方法」「可視化」「通知」「保持方針」まで含めて設計する必要がある
- 監視はメール通知だけでは不十分で、メトリクス化してダッシュボードで継続監視する方が運用しやすい
- サービスごとにログ出力先や形式、リージョン制約、命名制約が異なるため、実際に手を動かして確認する価値が高い
- AthenaやQuickSightを使うことで、S3に蓄積したログから傾向分析や調査を実施できる
- gateway → ALB → アプリ → DB のように経路ごとのログを追うと、障害箇所を切り分けやすい

## このフォルダの位置づけ

この学習は、単なるログ確認の練習ではなく、以下をまとめて扱う実践寄りの学習です。

- AWSログ運用の全体像を理解する
- 設計資料として整理する
- Terraformで再現可能な形にする
- CLIと可視化ツールで実際に確認する
- 障害調査や運用改善にどう使うかまで落とし込む

そのため、調査メモ、設計書、Terraformコード、CLI手順、検証結果が一つの流れとしてまとまっています。
