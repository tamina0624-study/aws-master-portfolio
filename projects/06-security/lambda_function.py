import boto3

def lambda_handler(event, context):
    waf = boto3.client('wafv2')
    ip_set_id = 'd3565089-fbb4-4d9a-832c-10367d66b2a9'
    scope = 'REGIONAL'  # or 'CLOUDFRONT'
    ip_set_name = 'guardduty_test'

    # 既存IPセットの取得
    response = waf.get_ip_set(Name=ip_set_name, Scope=scope, Id=ip_set_id)
    addresses = response['IPSet']['Addresses']
    lock_token = response['LockToken']

    # GuardDutyイベントから攻撃元IPを抽出し、IPセットに追加
    details = event['detail']['service']['action']['portProbeAction']['portProbeDetails']
    for probe in details:
        src_ip = probe['remoteIpDetails']['ipAddressV4']
        if src_ip and f"{src_ip}/32" not in addresses:
            addresses.append(f"{src_ip}/32")

    # IPセットを更新
    waf.update_ip_set(
        Name=ip_set_name,
        Scope=scope,
        Id=ip_set_id,
        Addresses=addresses,
        LockToken=lock_token
    )
