# ハイブリッドネットワーク構築（Site-to-Site VPNとBGPによる冗長化構成）

昨日の「エンタープライズランディングゾーン」の基盤の上に、オンプレミス環境とのセキュアな接続を想定したハイブリッドネットワークを構築します。
「ポートフォリオ作成戦略」の「1. ネットワーク：ハイブリッド接続の冗長化」に該当するフェーズです。

## User Review Required

> [!IMPORTANT]
> オンプレミス側の環境について確認させてください。
> このポートフォリオ作品において、実際の物理ルーター（ご自宅のYamahaルーターなど）とAWSを接続して検証を行いますか？
> それとも、AWS上に「オンプレミスを模した別のVPCとVPNルーター（EC2上のstrongSwan等）」を構築して、完全なシミュレーション環境としてTerraformでコード化しますか？
> 
> ※ポートフォリオとしてGitHub等で公開する場合は、後者（AWS上でオンプレミス環境もシミュレートする構成）にすると、面接官がアーキテクチャの全体像をコードで把握しやすいためおすすめです。

## Open Questions

- 今回構築するVPNのAWS側エンドポイントは、Virtual Private Gateway (VGW) を使用しますか？ それとも将来的な拡張を見越して Transit Gateway (TGW) を使用しますか？（まずは基本的なVGWで構成するのがシンプルです）
- BGPのAS番号（AWS側、オンプレ側）に指定はありますか？（指定がなければプライベートAS番号である `64512` 等を使用します）

## Proposed Changes

`projects/05-hybrid-network` ディレクトリを新規作成し、以下のインフラをTerraformで構築します。

### AWS側インフラ (projects/05-hybrid-network)

#### [NEW] providers.tf
- AWSプロバイダーの設定。

#### [NEW] vpc_aws.tf
- AWS側のVPC、サブネット、ルートテーブルの作成。

#### [NEW] vpn_aws.tf
- Virtual Private Gateway (VGW) の作成とVPCへのアタッチ。
- Customer Gateway (CGW) の作成（オンプレミス側のIPアドレスを指定、動的ルーティングのためのBGP AS番号を設定）。
- Site-to-Site VPN Connection の作成。2本のIPsecトンネルを持つ冗長構成。

#### [NEW] variables.tf / outputs.tf
- オンプレ側のIPアドレスなどを変数化。
- ダウンロード可能なVPN設定ファイル情報やステータスを出力。

### オンプレミス側インフラ（シミュレーションとする場合）

#### [NEW] vpc_onprem.tf
- オンプレミスを模したVPCの作成。

#### [NEW] router_onprem.tf
- EC2インスタンスをルーターとしてデプロイ。
- User Dataを用いて strongSwan (IPsec) と FRR (BGP) を自動インストール・設定し、AWSのVPNエンドポイントとのトンネルを自動確立させます。

## Verification Plan

### Automated Tests
- `terraform apply` の正常完了。

### Manual Verification
1. AWS CLI (`aws ec2 describe-vpn-connections`) またはマネジメントコンソールから、2本のVPNトンネルのステータスが `UP` になっていることを確認。
2. BGPによる経路情報の伝播（AWS側のルートテーブルにオンプレ側のCIDRが「伝播済み」として登録されているか）を確認。
3. フェイルオーバーの検証：一方のVPNトンネル（またはEC2ルーター側の1プロセス）を意図的にダウンさせ、もう一方のトンネルに通信が切り替わるかPing等でテストし、その結果をドキュメント化（MTU/MSSの考慮なども含む）。
