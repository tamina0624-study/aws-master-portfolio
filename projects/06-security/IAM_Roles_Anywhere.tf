resource "aws_rolesanywhere_trust_anchor" "example" {
  name = "my-trust-anchor"
  enabled = true
  source{
    source_type = "CERTIFICATE_BUNDLE"
    source_data {
      x509_certificate_data = file("ca_cert.pem")
    }
    }
}

resource "aws_iam_role" "rolesanywhere_role" {
  name = "rolesanywhere-demo-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "rolesanywhere.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rolesanywhere_policy" {
  role       = aws_iam_role.rolesanywhere_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # 必要に応じて変更
}

resource "aws_rolesanywhere_profile" "example" {
  name = "my-profile"
  enabled = true
  role_arns = [aws_iam_role.rolesanywhere_role.arn]
  session_policy = "" # 必要に応じて追加
}
