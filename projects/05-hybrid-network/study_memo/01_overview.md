# VPN構成まとめ（AWS Site-to-Site）

## 構成要素
- IPsec（strongSwan）
- VTI（仮想トンネルIF）
- BGP（FRR）

## 方式
- Route-based VPN（主流）
- Policy-based VPN（旧式）

## 全体の役割
- strongSwan：トンネル作成（IKE / Child SA）
- VTI：トンネルをインターフェース化
- BGP：ルーティング交換
- Linux：実際の転送制御
