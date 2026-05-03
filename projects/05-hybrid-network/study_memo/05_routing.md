# ルーティングの本質

## 重要
「どこに流すか」は ip route が決める

## 例
ip route add 192.168.0.0/16 dev vti-t1

## BGPとの関係
- BGP：ルートを配る
- カーネル：実際に転送

## ip rule
パケットの振り分け制御

例：
ip rule add fwmark 10 table 100
