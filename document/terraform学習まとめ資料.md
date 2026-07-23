# Terraform 学習まとめ

---

## 1. Terraformとは

Terraformはインフラをコードで管理するためのツール（IaC: Infrastructure as Code）。
AWSなどのクラウドリソースを自動で作成・変更・削除できる。

---

## 2. 全体像（図解）

```
[ Terraformコード (.tf) ]
            ↓
   (Terraformが解析)
            ↓
     差分を計算（plan）
            ↓
   AWS API を呼び出す
            ↓
 [ AWSリソースが作成される ]
```

 ポイント：AWSはTerraformコードを理解していない
 TerraformがAWS APIを操作している

---

## 3. 宣言的とは？（超重要）

```
× 手順を書く（どうやるか）
○ 状態を書く（どうなっていてほしいか）
```

例：
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
}
```

 「S3を作る手順」ではなく
 「このバケットが存在している状態」を宣言

---

## 4. 動作フロー（詳細）

```
① .tfファイルを読む
        ↓
② 現在の状態（state）を取得
        ↓
③ 差分を計算（plan）
        ↓
④ 必要な変更だけ実行（apply）
        ↓
⑤ stateを更新
```

---

## 5. 差分管理のイメージ

```
【理想】        【現在】
EC2あり   vs   EC2なし

        ↓ 差分

「EC2を作る必要あり」

        ↓

AWS API実行
```

 必要な分だけ変更するのが強み

---

## 6. 主要コンポーネント（図解）

```
[ Provider ] → AWSとの接続
      ↓
[ Resource ] → 作るもの（EC2, S3）
      ↓
[ State ]    → 現在の状態を記録
```

---

## 7. Terraform vs CloudFormation（構造比較）

### Terraform
```
Terraform → AWS API → AWS
（クライアント側主導）
```

### CloudFormation
```
テンプレート → AWS → AWSリソース
（AWS側主導）
```

---

## 8. Terraform vs CDK（構造比較）

### Terraform
```
HCL → そのまま実行
```

### CDK
```
コード → CloudFormation → AWS
```

 CDKは1段階多い

---

## 9. stateの役割（超重要）

```
[ stateファイル ]
  ・作成したリソース情報
  ・IDや設定値
```

 これがあるから差分が分かる

⚠️ 壊れると：
- 差分がおかしくなる
- リソース重複や削除事故

---

## 10. インストール構成

```
[ ローカルPC ]
  ├ Terraform
  ├ AWS CLI
  └ .tfファイル

        ↓

[ AWS ]（何もインストール不要）
```

---

## 11. 基本コマンドの流れ

```
terraform init   → 初期化
terraform plan   → 差分確認
terraform apply  → 実行
terraform destroy→ 削除
```

---

## 12. 重要ポイントまとめ

- Terraformは「状態差分エンジン」
- AWSはTerraformを解釈しない
- TerraformがAPIを叩く
- stateが最重要

---

## 13. 次のステップ

- stateの中身を理解
- module設計
- CI/CD連携
- 実際に環境を構築

---
