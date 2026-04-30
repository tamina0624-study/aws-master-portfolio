# コマンド集

## strongSwan
swanctl --load-all
swanctl --list-sas
swanctl --initiate

## VTI
ip tunnel show
ip addr show dev vti-t1

## ルーティング
ip route
ip rule

## パケット確認
tcpdump -i vti-t1
tracepath <IP>
