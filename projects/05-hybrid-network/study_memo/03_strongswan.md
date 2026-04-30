# strongSwan設定

## 設定ファイル
/etc/swanctl/swanctl.conf

## 基本構造
connections {
  conn-name {
    local_addrs = xxx
    remote_addrs = xxx

    local { id = xxx }
    remote { id = xxx }

    children {
      child-name {
        local_ts = 0.0.0.0/0
        remote_ts = 0.0.0.0/0
      }
    }
  }
}

## 重要概念
- IKE SA：制御用（認証・鍵交換）
- Child SA：実通信トンネル

## local_addrs vs id
- local_addrs：実際の送信元IP
- id：認証時の名乗り
