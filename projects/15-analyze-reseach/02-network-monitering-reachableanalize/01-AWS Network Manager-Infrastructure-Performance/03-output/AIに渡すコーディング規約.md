Read [](file:///c%3A/Users/0018550835/Desktop/%E6%A1%88%E4%BB%B6/portforio/aws-master-portfolio/projects/15-analyze-reseach/02-network-monitering-reachableanalize/01-AWS%20Network%20Manager-Infrastructure-Performance)

Read [](file:///c%3A/Users/0018550835/Desktop/%E6%A1%88%E4%BB%B6/portforio/aws-master-portfolio/projects/15-analyze-reseach/02-network-monitering-reachableanalize/01-AWS%20Network%20Manager-Infrastructure-Performance/02-terraform)

Read [](file:///c%3A/Users/0018550835/Desktop/%E6%A1%88%E4%BB%B6/portforio/aws-master-portfolio/projects/15-analyze-reseach/02-network-monitering-reachableanalize/01-AWS%20Network%20Manager-Infrastructure-Performance/01-doc)

Read [](file:///c%3A/Users/0018550835/Desktop/%E6%A1%88%E4%BB%B6/portforio/aws-master-portfolio/projects/15-analyze-reseach/02-network-monitering-reachableanalize/01-AWS%20Network%20Manager-Infrastructure-Performance/02-terraform/module)

Read [](file:///c%3A/Users/0018550835/Desktop/%E6%A1%88%E4%BB%B6/portforio/aws-master-portfolio/projects/15-analyze-reseach/02-network-monitering-reachableanalize/01-AWS%20Network%20Manager-Infrastructure-Performance/02-terraform/main.tf)

Read [](file:///c%3A/Users/0018550835/Desktop/%E6%A1%88%E4%BB%B6/portforio/aws-master-portfolio/projects/15-analyze-reseach/02-network-monitering-reachableanalize/01-AWS%20Network%20Manager-Infrastructure-Performance/02-terraform/module/ec2)

Read [](file:///c%3A/Users/0018550835/Desktop/%E6%A1%88%E4%BB%B6/portforio/aws-master-portfolio/projects/15-analyze-reseach/02-network-monitering-reachableanalize/01-AWS%20Network%20Manager-Infrastructure-Performance/02-terraform/module/vpc)

Read memory [](file:///c%3A/Users/0018550835/AppData/Roaming/Code/User/workspaceStorage/03751b93f4b936f3ef9f0f97a098e706/GitHub.copilot-chat/memory-tool/memories/repo/terraform-module-style.md)

Read [](file:///c%3A/Users/0018550835/Desktop/%E6%A1%88%E4%BB%B6/portforio/aws-master-portfolio/projects/15-analyze-reseach/02-network-monitering-reachableanalize/01-AWS%20Network%20Manager-Infrastructure-Performance/02-terraform/module/ec2/main.tf#1-1), lines 1 to 30

この構成のパターンを整理した上で、AIへの指示テンプレートを作成します。

---

## この構成の特徴（パターン整理）

```
02-terraform/
├── main.tf          # 目次・導線（module呼び出し）
├── providers.tf
├── outputs.tf
└── module/
    ├── vpc/
    │   ├── main.tf, variables.tf, outputs.tf, README.md
    │   ├── transit_gateway.tf, vpn_connection.tf  # リソース別ファイル分割
    │   ├── aws_vpc1/   (サブmodule)
    │   ├── aws_vpc2/   (サブmodule)
    │   └── as_onpremise/ (サブmodule)
    └── ec2/
        ├── main.tf, variables.tf, outputs.tf, README.md
        ├── common/     (共通IAM)
        ├── aws_vpc1/   (サブmodule)
        ├── aws_vpc2/   (サブmodule)
        └── as_onpremise/ (サブmodule)
```

---

## AIへの指示テンプレート

以下をそのままコピーして使えます。`【】`部分を案件に合わせて書き換えてください。

---

```
以下の方針でTerraformのディレクトリ構成とファイルを作成してください。

## 構成方針

### ディレクトリ構造
02-terraform/
├── main.tf          # ルート（目次・導線のみ。module呼び出しをする）
├── providers.tf     # providerとbackend定義
├── outputs.tf       # ルートoutput
└── module/
    ├── 【サービス1 例:vpc】/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── README.md
    │   ├── 【リソース別.tf 例:transit_gateway.tf】
    │   ├── 【サブmodule1 例:aws_vpc1】/
    │   └── 【サブmodule2 例:aws_vpc2】/
    └── 【サービス2 例:ec2】/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── README.md
        ├── common/   # 共通リソース（IAMロール等）
        ├── 【サブmodule1】/
        └── 【サブmodule2】/

### コーディング規約
- **ルートmain.tf** は目次・導線役割。冒頭にコメントで構成ファイル一覧・注意事項・初見者向け導線を記載する
- **module内** はpure module方針。環境依存値・サービス固有値は変数で受け取るだけにする
- 各main.tfの冒頭コメントに以下を必ず記載する
  - 構成ファイル一覧
  - 注意事項
  - 初見者向け導線
- 冗長でも明示的な記述を優先する
- リソースが多い場合はmain.tf内に全て書かず、リソース種別ごとに.tfファイルを分割する

### 対象構成
【ここに作りたいAWSアーキテクチャを記述する
例：
- VPC x2（本番・検証）
- オンプレ模擬VPC x1（Transit Gateway経由で接続）
- 各VPCにEC2を1台ずつ配置（SSM接続）
- Transit Gatewayで3VPCをメッシュ接続
】

### 作成手順
1. まずディレクトリ構成のツリーを提示してください
2. 確認後、ルートのmain.tf / providers.tf / outputs.tf を作成してください
3. 次にmodule/【サービス1】配下を作成してください
4. 最後にmodule/【サービス2】配下を作成してください
```

---

## ポイント解説

| 指示のコツ | 理由 |
|---|---|
| **手順を段階的に指定する** | 一度に全部作ると構成がブレやすい |
| **「まずツリーを提示」** | 認識齟齬を防ぎ、修正コストを減らす |
| **pure module方針を明記** | AIがルートに直書きしてしまうのを防ぐ |
| **コメント規約を明記** | このプロジェクトの目次スタイルを再現させる |
