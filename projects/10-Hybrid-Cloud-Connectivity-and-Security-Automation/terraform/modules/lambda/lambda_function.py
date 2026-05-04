import boto3
import os

def extract_attacker_ips(event):
    """
    GuardDuty Findingイベントから攻撃元IPアドレスを抽出（複数タイプ対応）
    """
    ips = set()
    detail = event.get('detail', {})
    service = detail.get('service', {})
    action = service.get('action', {})

    # portProbeAction
    port_probe = action.get('portProbeAction', {})
    for probe in port_probe.get('portProbeDetails', []):
        ip = probe.get('remoteIpDetails', {}).get('ipAddressV4')
        if ip:
            ips.add(ip)

    # networkConnectionAction
    net_conn = action.get('networkConnectionAction', {})
    ip = net_conn.get('remoteIpDetails', {}).get('ipAddressV4')
    if ip:
        ips.add(ip)

    # unauthorizedAccess, backdoor, etc.（他パターンも必要に応じて追加）
    # ...

    return ips

def lambda_handler(event, context):
    waf = boto3.client('wafv2')
    # Terraformでdeny-ipsetを作成しているため、ここで明示的に参照
    ip_set_id = os.environ.get('WAFV2_IP_SET_ID', 'REPLACE_WITH_TF_OUTPUT')  # 例: tf outputで渡す
    ip_set_name = os.environ.get('WAFV2_IP_SET_NAME', 'deny-ipset')
    scope = os.environ.get('WAFV2_SCOPE', 'REGIONAL')

    try:
        response = waf.get_ip_set(Name=ip_set_name, Scope=scope, Id=ip_set_id)
        addresses = response['IPSet']['Addresses']
        lock_token = response['LockToken']
    except Exception as e:
        print(f"[ERROR] get_ip_set failed: {e}")
        return {'status': 'error', 'reason': str(e)}

    attacker_ips = extract_attacker_ips(event)
    updated = False
    for ip in attacker_ips:
        cidr = f"{ip}/32"
        if cidr not in addresses:
            addresses.append(cidr)
            updated = True

    if updated:
        try:
            waf.update_ip_set(
                Name=ip_set_name,
                Scope=scope,
                Id=ip_set_id,
                Addresses=addresses,
                LockToken=lock_token
            )
            print(f"[INFO] Blocked IPs added: {attacker_ips}")
            return {'status': 'updated', 'ips': list(attacker_ips)}
        except Exception as e:
            print(f"[ERROR] update_ip_set failed: {e}")
            return {'status': 'error', 'reason': str(e)}
    else:
        print("[INFO] No new IPs to add.")
        return {'status': 'no_update'}
