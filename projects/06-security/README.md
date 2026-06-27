# 06 Security

---

> 「不審なポートスキャンが来ているのをセキュリティチームが検知した時には、
> すでに数十分が経過していた。手動でブロックするまでにさらに時間がかかってしまった。」

> 「攻撃を検知する仕組みはあるのに、ブロックする作業が手作業なので追いつかない。」

セキュリティの理想は「検知したら即座に遮断する」自律防御です。
**AWS GuardDuty** は機械学習と脅威インテリジェンスを使って不審な通信を自動検知します。
それを **EventBridge** でキャッチし **Lambda** を起動、攻撃元 IP を **WAF** の拒否リストへ自動登録する仕組みを組み合わせることで、人手を介さない自動対応ループが完成します。
脅威を「知るだけ」で終わらせず「止めるまで自動化する」ことが、現代のクラウドセキュリティの考え方です。

本プロジェクトは、その検知から自動遮断までの一連のフローを Terraform で実装した学習成果です。

---

GuardDuty が検知した脅威を EventBridge でキャッチし、Lambda が自動的に WAF の IP セットへブロック登録する自律防御の仕組みを Terraform で構築した。

---

## 自動防御フロー

```
                    脅威検知
  ┌─────────────┐         ┌──────────────────┐
  │  GuardDuty  │────────▶│   EventBridge    │
  │  (ポートスキャン      │  (PortProbeAction │
  │   検知)     │         │   イベントルール)  │
  └─────────────┘         └────────┬─────────┘
                                   │ 自動起動
                                   ▼
                          ┌──────────────────┐
                          │  Lambda 関数     │
                          │                  │
                          │ 攻撃元 IP を     │
                          │ イベントから抽出  │
                          └────────┬─────────┘
                                   │ IP 追加
                                   ▼
                          ┌──────────────────┐
                          │  WAF v2 IP Set   │
                          │  (拒否リスト)    │
                          │                  │
                          │  → ALB へのアク  │
                          │    セスをブロック │
                          └──────────────────┘
```

---

## 実装内容

### GuardDuty（GuardDuty.tf）
- GuardDuty の有効化と EventBridge との連携設定
- PortProbeAction イベントをトリガーとして Lambda を呼び出す

### Lambda 自動対応（lambda_function.py）
```python
# GuardDutyイベントから攻撃元IPを抽出してWAF IP Setへ追加
details = event['detail']['service']['action']['portProbeAction']['portProbeDetails']
for probe in details:
    src_ip = probe['remoteIpDetails']['ipAddressV4']
    # 重複チェック後、/32 でIPセットに追加
    addresses.append(f"{src_ip}/32")
waf.update_ip_set(...)
```

### IAM Roles Anywhere（IAM_Roles_Anywhere.tf）
- 証明書ベースの認証で、オンプレミスワークロードへ一時認証情報を発行
- 長期アクセスキーを使わない外部認証の実践例

---

## ファイル構成

```
06-security/
├── GuardDuty.tf          # GuardDuty + EventBridge ルール
├── IAM_Roles_Anywhere.tf # IAM Roles Anywhere（外部認証）
├── lambda_function.py    # 自動 IP ブロック Lambda
├── lambda_function.zip   # Lambda デプロイパッケージ
├── main.tf
└── providers.tf
```

---

## 設計のポイント

| 観点 | 実装内容 |
|------|---------|
| 自動化 | 脅威検知から IP ブロックまで人手不要 |
| 冪等性 | IP 重複チェックで二重登録を防止 |
| 最小権限 | Lambda には WAF 更新権限のみ付与 |
| 外部認証 | IAM Roles Anywhere で長期キーを排除 |

---

## 実行方法

```bash
terraform init
terraform apply

# GuardDuty のサンプル脅威を生成して動作確認
aws guardduty create-sample-findings \
  --detector-id <DETECTOR_ID> \
  --finding-types "Recon:EC2/PortProbeUnprotectedPort"
```
