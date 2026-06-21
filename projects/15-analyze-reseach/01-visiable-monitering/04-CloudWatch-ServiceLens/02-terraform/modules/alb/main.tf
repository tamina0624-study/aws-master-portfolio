
# ================================
# ALB module main.tf（人間向け目次・導線）
# ================================
# このディレクトリはALB関連のmoduleです。
#
# 【構成ファイル一覧】
#   - alb.tf                  : ALB本体リソース
#   - target_group.tf         : ターゲットグループ
#   - listener.tf             : リスナー
#   - target_group_attachment.tf : ターゲットグループアタッチメント
#   - variables.tf            : 変数定義
#   - outputs.tf              : 出力値定義
#
# 【注意事項】
# - module内はpure module方針
# - 環境依存・サービス固有値は受け取るだけ
# - 冗長でも明示的な記述を優先
#
# 【初見者向け導線】
# まずはこのmain.tfとREADME.mdを参照してください。
