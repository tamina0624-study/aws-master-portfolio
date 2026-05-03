# AWS SSO（IAM Identity Center）と権限管理 学習まとめ

## 1. 目的・ゴール
- AWS IAM Identity Center（旧SSO）を活用したエンタープライズ基準のID・アクセス管理を理解・実践
- Terraformによる自動化設計と、手動運用・台帳管理の両立方法を学ぶ

---

## 2. 学習内容の流れ

### 2.1 SSOユーザー・グループの作成
- Terraformでaws_identitystore_user, aws_identitystore_groupリソースを用いてユーザー・グループを作成
- グループメンバーシップもコード化可能
- Organizations権限がない場合、Permission SetやAccount Assignmentは手動運用

### 2.2 SSO権限設計パターン
- 管理者（AdministratorAccess）、開発者（PowerUserAccess）、監査用（SecurityAudit）、最小権限（ReadOnlyAccess）など職務ごとにPermission Setを設計
- グループ単位でPermission Setを割り当てることで運用効率・セキュリティを両立

### 2.3 Account Assignment（割り当て）
- Organizations有効時はTerraformでAccount Assignmentも自動化可能
- principal_type（USER/GROUP）、target_id（AWSアカウントID）などを指定

### 2.4 権限ライフサイクル設計
- 入社：ユーザー作成→グループ追加→権限自動付与
- 異動：グループ変更で権限自動切替
- 退職：ユーザー削除で権限即時剥奪
- すべてコード管理・Git管理でトレーサビリティ確保

### 2.5 手動運用フロー・台帳管理
- Excelやスプレッドシートで「ユーザー・グループ・権限割り当て台帳」を管理
- 台帳とAWS実態の定期突合、申請・承認フローの記録、監査証跡として活用

### 2.6 台帳→Terraform自動生成
- Python等でCSV台帳からTerraformコードを自動生成するスクリプト例を学習
- 台帳とIaCの連携で運用効率・ガバナンスを強化

---

## 3. 実務でのポイント
- コード管理（IaC）と台帳管理の両輪運用がベストプラクティス
- 権限設計・割り当てルール・運用フローを明文化し、属人化を防ぐ
- 将来的なOrganizations権限取得時に備え、設計・コード雛形を準備しておく

---

## 4. 参考テンプレート・雛形
- Terraformコード雛形（Permission Set/Account Assignment）
- Excel台帳雛形
- Pythonスクリプト雛形（CSV→Terraform）
- 手動運用フロー雛形

---

## 5. まとめ

AWS SSO（IAM Identity Center）による権限管理は、設計・自動化・運用台帳・監査のバランスが重要であることを学んだ。
また、システムとしてどのような仕組みを作るかだけでなく、多数の人が連携するための管理ドキュメントや運用ルールの整備・運用方法が、システム以上に重要であると強く感じた。

Organizations権限がない場合でも、ユーザー・グループ管理や運用台帳の整備、将来の自動化設計準備は十分に価値がある。
現実的な制約下でも「できることを積み上げる」姿勢が、実務やキャリアの成長につながると実感した。

---

## 6. 実践エピソード・所感

- 当初の目標は「Organizations配下でのSSO権限自動化」だったが、管理権限がなく実現できなかった。
- 妥協案として、TerraformでSSOユーザー・グループの作成のみ実施。
- SSOユーザーでAWSアクセスポータルURLからログインはできたが、権限割り当てができず何も操作できなかった。
- 「何もできないSSOユーザーでログインできた」だけで終わるという、少し情けない（でも現実的な）学習体験となった。

この経験を活かし、今後Organizations権限が得られた際は、設計・自動化をすぐに実践できるよう準備しておく。
