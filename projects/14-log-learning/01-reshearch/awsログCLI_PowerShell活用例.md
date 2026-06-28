# AWS CLIとPowerShellによるログ抽出例

## 1. CloudWatch Logsの基本コマンド
- ロググループ一覧取得
  ```
  aws logs describe-log-groups
  ```
- ログストリーム一覧取得
  ```
  aws logs describe-log-streams --log-group-name <ロググループ名>
  ```
- ログイベント（実際のログ）取得
  ```
  aws logs get-log-events --log-group-name <ロググループ名> --log-stream-name <ログストリーム名>
  ```

## 2. 出力形式
- デフォルトはJSON
- `--output text` や `--output table` でテキストや表形式も可能

## 3. PowerShellでのキーワード絞り込み例
- CLI出力をPowerShellのパイプでつなぎ、`Select-String`でキーワード抽出
  ```
  aws logs get-log-events --log-group-name <ロググループ名> --log-stream-name <ログストリーム名> | Select-String "Error"
  ```
- jqコマンドと組み合わせてJSONの特定フィールドのみ抽出し、さらにPowerShellで絞り込むことも可能

---

AWS CLIとPowerShellを組み合わせることで、柔軟なログ検索・抽出が可能です。
