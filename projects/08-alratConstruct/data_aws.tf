# ==========================================
# 既存のAWS環境（01-basic-infrastructure）の参照
# ==========================================

# 過去のプロジェクトのStateファイルを読み込む
data "terraform_remote_state" "basic_infra" {
  backend = "local"
  config = {
    path = "../01-basic-infrastructure/terraform.tfstate"
  }
}

# 既存のパブリックサブネットに関連付けられているルートテーブルを自動検索して取得
data "aws_route_table" "aws_public_rt" {
  subnet_id = data.terraform_remote_state.basic_infra.outputs.subnet_public_1_id
}
