
import { Stack, StackProps, Duration } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as fs from 'fs';

export class BasicInfrastructureCdkStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    // パラメータ
    const projectName = 'portfolio';
    const vpcCidr = '10.0.0.0/16';
    const subnet1Cidr = '10.0.1.0/24';
    const subnet2Cidr = '10.0.2.0/24';

    // VPC
    const vpc = new ec2.Vpc(this, 'Vpc', {
      cidr: vpcCidr,
      maxAzs: 2,
      subnetConfiguration: [
        {
          cidrMask: 24,
          name: 'PublicSubnet1',
          subnetType: ec2.SubnetType.PUBLIC,
        },
        {
          cidrMask: 24,
          name: 'PublicSubnet2',
          subnetType: ec2.SubnetType.PUBLIC,
        },
      ],
      natGateways: 0,
    });

    // セキュリティグループ
    const myIp = '0.0.0.0/0'; // 必要に応じて自分のIPに変更
    const sg = new ec2.SecurityGroup(this, 'PortfolioSG', {
      vpc,
      securityGroupName: `${projectName}-sg`,
      description: 'Allow SSH and HTTP',
      allowAllOutbound: true,
    });
    sg.addIngressRule(ec2.Peer.ipv4(myIp), ec2.Port.tcp(22), 'Allow SSH');
    sg.addIngressRule(ec2.Peer.ipv4(myIp), ec2.Port.tcp(80), 'Allow HTTP');

    // キーペア名
    const keyName = 'portfolio-key';

    // EC2インスタンス
    const ami = ec2.MachineImage.latestAmazonLinux2023();
    const instance = new ec2.Instance(this, 'PortfolioWebServer', {
      vpc,
      vpcSubnets: { subnetType: ec2.SubnetType.PUBLIC },
      instanceType: ec2.InstanceType.of(ec2.InstanceClass.T2, ec2.InstanceSize.MICRO),
      machineImage: ami,
      securityGroup: sg,
      keyName: keyName,
      userData: ec2.UserData.custom(`#!/bin/bash\ndnf update -y\ndnf install -y httpd\nsystemctl start httpd\nsystemctl enable httpd\necho '<h1>CDKで自動構築したWebサーバー</h1>' > /var/www/html/index.html`),
    });

    // 必要に応じてキーペアの作成はAWS CLIやマネジメントコンソールで事前に行ってください
    // CDKからキーペア作成はできません（CloudFormation制約）
  }
}
