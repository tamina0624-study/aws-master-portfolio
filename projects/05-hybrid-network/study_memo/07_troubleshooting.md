# トラブルシュート

## VPN確認
swanctl --list-sas

## BGP確認
vtysh -c "show ip bgp summary"

## ルート確認
ip route

## よくある問題
- rp_filter有効 → 通信NG
- TS不一致 → Child SA張れない
- routeなし → 通信流れない
- fwmarkミス
