# SSOインスタンス取得
data "aws_ssoadmin_instances" "this" {}

# Permission Set（例：管理者）
resource "aws_ssoadmin_permission_set" "admin" {
  name         = "AdministratorAccess"
  description  = "Full admin access"
  instance_arn = data.aws_ssoadmin_instances.this.arns[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Permission Set（例：開発者）
resource "aws_ssoadmin_permission_set" "developer" {
  name         = "DeveloperAccess"
  description  = "Power user access"
  instance_arn = data.aws_ssoadmin_instances.this.arns[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "developer" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Permission Set（例：監査用）
resource "aws_ssoadmin_permission_set" "audit" {
  name         = "SecurityAudit"
  description  = "Security audit access"
  instance_arn = data.aws_ssoadmin_instances.this.arns[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "audit" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.audit.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

# Permission Set（例：最小権限）
resource "aws_ssoadmin_permission_set" "readonly" {
  name         = "ReadOnlyAccess"
  description  = "Read only access"
  instance_arn = data.aws_ssoadmin_instances.this.arns[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# 例：開発者グループにDeveloperAccessを割り当てる
resource "aws_ssoadmin_account_assignment" "developer_assignment" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  principal_id       = aws_identitystore_group.developer.group_id  # グループID
  principal_type     = "GROUP"
  target_id          = "<AWSアカウントID>"  # 割り当て先アカウントID
  target_type        = "AWS_ACCOUNT"
}

# 例：監査ユーザーにSecurityAuditを割り当てる
resource "aws_ssoadmin_account_assignment" "audit_assignment" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.audit.arn
  principal_id       = aws_identitystore_user.audit.user_id  # ユーザーID
  principal_type     = "USER"
  target_id          = "<AWSアカウントID>"
  target_type        = "AWS_ACCOUNT"
}
