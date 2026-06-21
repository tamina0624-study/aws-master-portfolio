# ec2 module variables
variable "vpc" {
  description = "vpc定義"
  type        = any
  default     = null
}

variable "iam" {
  description = "iam定義"
  type        = any
  default     = null
}


variable "ami" {
  description = "AMI ID"
  type        = string
  default     = ""
}
variable "instance_type" {
  description = "インスタンスタイプ"
  type        = string
  default     = "t3.micro"
}
variable "key_name" {
  description = "キーペア名"
  type        = string
  default     = null
  nullable    = true
}
variable "associate_public_ip_address" {
  description = "パブリックIP付与"
  type        = bool
  default     = true
}
variable "root_volume_size" {
  description = "ルートボリュームサイズ"
  type        = number
  default     = 8
}
variable "root_volume_type" {
  description = "ルートボリュームタイプ"
  type        = string
  default     = "gp2"
}

variable "ec2_ssm_role_name" {
  description = "Session Manager用EC2 IAMロール名"
  type        = string
  default     = "analyze-research-ec2-ssm-role-common"
}

variable "ec2_ssm_instance_profile_name" {
  description = "Session Manager用EC2インスタンスプロファイル名"
  type        = string
  default     = "analyze-research-ec2-ssm-instance-profile-common"
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to the instance"
  type        = string
  default     = null
}

variable "tags_web" {
  description = "タグ"
  type        = map(string)
  default = {
    Name        = "web-server-as-onpremise"
    Environment = "dev"
  }
}

variable "tags_router" {
  description = "タグ"
  type        = map(string)
  default = {
    Name        = "router-server-as-onpremise"
    Environment = "dev"
  }
}


variable "user_data" {
  description = "ユーザーデータ"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    if ! command -v python3 >/dev/null 2>&1; then
      echo "python3 is required but not found" >&2
      exit 1
    fi

    mkdir -p /opt/simple-web
    cat <<'HTML' > /opt/simple-web/index.html
    <!doctype html>
    <html lang="ja">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>RUM Lab</title>
      <script>
        (function(n,i,v,r,s,c,x,z){
          x=window.AwsRumClient={q:[],n:n,i:i,v:v,r:r,c:c};
          window[n]=function(c,p){x.q.push({c:c,p:p});};
          z=document.createElement('script');
          z.async=true;
          z.src=s;
          document.head.insertBefore(z,document.getElementsByTagName('script')[0]);
        })('cwr',
           '01c976d5-94e4-48b0-b1ad-18c42904e239',
           '1.0.0',
           'us-east-2',
           'https://client.rum.us-east-1.amazonaws.com/1.0.2/cwr.js',
           {
             guestRoleArn: 'arn:aws:iam::638892640336:role/service-role/RUM-Monitor-us-east-2-638892640336-1122669001871-Unauth',
             identityPoolId: 'us-east-2:5e37082f-56a2-40eb-8293-9a23395a6c46',
             endpoint: 'https://dataplane.rum.us-east-2.amazonaws.com',
             sessionSampleRate: 1,
             telemetries: ['performance', 'errors', 'http'],
             allowCookies: true,
             enableXRay: false
           }
        );
      </script>
    </head>
    <body>
      <h1>Hello from EC2</h1>
      <p>CloudWatch RUM lab page</p>
      <script>
        window.addEventListener('load', function () {
          if (typeof cwr === 'function') {
            cwr('recordPageView');
          }
        });
      </script>
    </body>
    </html>
    HTML

    cat <<'UNIT' > /etc/systemd/system/simple-web.service
    [Unit]
    Description=Simple Python Web Server
    After=network.target

    [Service]
    Type=simple
    ExecStart=/usr/bin/python3 -m http.server 80 --bind 0.0.0.0 --directory /opt/simple-web
    Restart=always

    [Install]
    WantedBy=multi-user.target
    UNIT

    systemctl daemon-reload
    systemctl enable --now simple-web.service
	EOF
}

variable "onprem_vpc_cidr" {
  description = "オンプレミスVPCのCIDRブロック（BGP広報用）"
  type        = string
  default     = "10.16.0.0/16"
}

variable "onprem_bgp_asn" {
  description = "オンプレミス側 BGP ASN（Customer Gateway と一致させること）"
  type        = number
  default     = 65000
}

variable "aws_bgp_asn" {
  description = "AWS側 BGP ASN（Transit Gateway の amazon_side_asn デフォルト値）"
  type        = number
  default     = 64512
}

variable "aws_vpc1_cidr" {
  description = "AWS VPC1 の CIDRブロック（オンプレルーター静的ルート用）"
  type        = string
  default     = "10.14.0.0/16"
}

variable "aws_vpc2_cidr" {
  description = "AWS VPC2 の CIDRブロック（オンプレルーター静的ルート用）"
  type        = string
  default     = "10.15.0.0/16"
}

# user_data_router はリソース依存値（VPNトンネル情報）を含むため、
# locals.tf 内の local.user_data_router で templatefile を展開する。
# この変数は使用しないが、既存 instance.tf との互換性維持のため残す。
variable "user_data_router" {
  description = "ルーター用ユーザーデータ（未使用: locals.tf の local.user_data_router を参照）"
  type        = string
  default     = null
}
