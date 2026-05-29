# Welcome to your CDK TypeScript project

This is a blank project for CDK development with TypeScript.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

## Useful commands

* `npm run build`   compile typescript to js
* `npm run watch`   watch for changes and compile
* `npm run test`    perform the jest unit tests
* `npx cdk deploy`  deploy this stack to your default AWS account/region
* `npx cdk diff`    compare deployed stack with current state
* `npx cdk synth`   emits the synthesized CloudFormation template

---

# デプロイまでの実行コマンド・発生したエラーと対処法

## 実行した主なコマンド

1. CDKプロジェクト初期化
```
npx cdk init app --language typescript
```
2. 依存パッケージインストール
```
npm install aws-cdk-lib constructs
```
3. TypeScriptビルド
```
npm run build
```
4. CDKテンプレート生成
```
npx cdk synth
```
5. CDKブートストラップ（初回のみ）
```
npx cdk bootstrap
```
6. EC2用キーペア作成（AWS CLI）
```
aws ec2 create-key-pair --key-name portfolio-key --query 'KeyMaterial' --output text > securet/portfolio-key.pem
```
7. CDKデプロイ
```
npx cdk deploy
```

---

## 発生した主なエラーと対処法

### 1. 依存パッケージの不整合エラー
- 内容：`Cannot find module './assert-valid-pattern.js'` など
- 対処：`node_modules`と`package-lock.json`を削除し、`npm install`で再インストール

### 2. CDKデプロイ時のエラー
- 内容：`SSM parameter /cdk-bootstrap/hnb659fds/version not found` など
- 対処：`npx cdk bootstrap` を実行し、CDK用の初期リソースを作成

### 3. EC2インスタンス作成失敗
- 内容：`The key pair 'portfolio-key' does not exist`（キーペアが存在しない）
- 対処：AWS CLIで `aws ec2 create-key-pair --key-name portfolio-key ...` を実行し、キーペアを作成

---

## コマンド詳細説明

1. **CDKプロジェクト初期化**
   - `npx cdk init app --language typescript`
   - AWS CDKの新規プロジェクトをTypeScriptで初期化します。必要なディレクトリや設定ファイル（cdk.json, tsconfig.json, package.json など）が自動生成されます。

2. **依存パッケージインストール**
   - `npm install aws-cdk-lib constructs`
   - AWS CDKでAWSリソースを操作するためのライブラリ（aws-cdk-lib）と、CDKの基盤となるconstructsパッケージをインストールします。

4. **CDKテンプレート生成**
   - `npx cdk synth`
   - CDKで記述したTypeScriptコードからCloudFormationテンプレート（YAML/JSON）を生成します。構文エラーやリソース定義の問題がないかもこの時点で検証されます。

5. **CDKブートストラップ（初回のみ）**
   - `npx cdk bootstrap`
   - CDKでデプロイを行うために必要なS3バケットやIAMロールなどの初期リソースを、指定したAWSアカウント・リージョンに自動作成します。初回のみ必要です。

---

上記の手順・対処で無事にCDKデプロイが完了しました。
