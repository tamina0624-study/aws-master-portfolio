# FRR（BGP）

## 設定ファイル
/etc/frr/frr.conf

## 基本設定
router bgp 65000
 bgp router-id 169.254.49.225

 neighbor 169.254.49.226 remote-as 65001

 address-family ipv4 unicast
  neighbor 169.254.49.226 activate
  network 10.0.0.0/16
 exit-address-family

## 用語
- AS番号：ルータのグループ
- neighbor：接続先
- network：広告するネットワーク

## 動作
BGP → ルート受信 → ip routeに反映 → VPNに流れる
