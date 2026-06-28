# ================================
# Lambda module main.tf（人間向け目次・導線）
# ================================
# このディレクトリはLambda + API Gateway関連のmoduleです。
#
# 【構成ファイル一覧】
#   - lambda.tf      : Lambda本体と実行ロール
#   - apigateway.tf  : API Gateway HTTP APIとLambda統合
#   - variables.tf   : 変数定義
#   - outputs.tf     : 出力値定義
#
# 【注意事項】
# - module内はpure module方針
# - 環境依存・サービス固有値は受け取るだけ
# - 冗長でも明示的な記述を優先
#
# 【初見者向け導線】
# まずはこのmain.tfとREADME.mdを参照してください。
