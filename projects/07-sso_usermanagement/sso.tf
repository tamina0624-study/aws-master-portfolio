# SSOインスタンス取得（Identity Centerは1アカウント1つのみ）
data "aws_ssoadmin_instances" "this" {}




# SSOユーザー（Identity Center Directoryに直接作成する場合）
resource "aws_identitystore_user" "dev_user" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = "dev-user"
  display_name      = "Developer User"
  name {
    given_name  = "xxxxxx"
    family_name = "xxxxxx"
  }
  emails {
    value   = "xxxxx.g.xxxxxx@xxx.xxx"
    primary = true
  }
}

# SSOグループ
resource "aws_identitystore_group" "dev_group" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  display_name      = "Developers"
  description       = "Developer group"
}

# ユーザーをグループに追加
resource "aws_identitystore_group_membership" "dev_membership" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  group_id          = aws_identitystore_group.dev_group.group_id
  member_id         = aws_identitystore_user.dev_user.user_id
}
