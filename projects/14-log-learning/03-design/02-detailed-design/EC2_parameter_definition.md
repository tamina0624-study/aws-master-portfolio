# EC2パラメータ定義

このファイルは、簡単なWebサービスをホストするEC2インスタンスのパラメータ定義例です。

## 基本パラメータ

| パラメータ名         | 値例                        | 説明                         |
|----------------------|-----------------------------|------------------------------|
| Name                 | web-server                  | インスタンス名               |
| InstanceType         | t3.micro                    | インスタンスタイプ           |
| AMI                  | ami-0c02fb55956c7d316       | Amazon Linux 2（us-east-2公式）|
| KeyName              | my-key-pair                 | SSHキーペア名                |
| SecurityGroupIds     | log-learning-ec2-web-sg        | log-learning-sg（共通SG）     |
| SubnetId             | subnet-public-10.14.1.0/24  | log-learning-public-subnet    |
| AssociatePublicIp    | true                        | パブリックIP付与             |
| RootVolumeSize       | 8                           | ルートボリュームサイズ(GB)    |
| RootVolumeType       | gp2                         | ルートボリュームタイプ        |
| Tag                  | Environment=dev             | タグ                         |

## セキュリティグループ例

- HTTP(80), HTTPS(443), SSH(22) を許可

## ユーザーデータ例

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "Hello from EC2" > /var/www/html/index.html
```

## 備考
- OSはAmazon Linux 2（AMI: ami-0c02fb55956c7d316, us-east-2）
- サブネットはlog-learning-public-subnet（10.14.1.0/24）を利用
- 必要に応じてパラメータを調整してください。
