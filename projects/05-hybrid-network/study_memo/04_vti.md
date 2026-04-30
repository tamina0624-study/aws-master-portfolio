# VTI（仮想トンネル）

## 作成
ip tunnel add vti-t1 local 172.16.0.223 remote 3.18.50.193 mode vti key 10

## 有効化
ip link set vti-t1 up

## IP付与
ip addr add 169.254.49.225/30 dev vti-t1

## 削除
ip tunnel del vti-t1

## sysctl
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.rp_filter=0