# BigBlueButton 3.0.28 — Hướng dẫn Triển khai & Cài đặt

> Ngày phát hành: 29/05/2026 | Ubuntu 22.04 LTS (Jammy)
> Tài liệu tham khảo: [GitHub Releases](https://github.com/bigbluebutton/bigbluebutton/releases) | [Docs chính thức](https://docs.bigbluebutton.org/administration/install/)

---

## Mục lục

- [1. Tổng quan về BBB 3.0.28](#1-tổng-quan-về-bbb-3028)
- [2. Tính năng mới trong 3.0.28](#2-tính-năng-mới-trong-3028)
- [3. So sánh phiên bản 3.0.x](#3-so-sánh-phiên-bản-30x)
- [4. Yêu cầu hệ thống](#4-yêu-cầu-hệ-thống)
- [5. Kiến trúc thiết kế triển khai](#5-kiến-trúc-thiết-kế-triển-khai)
- [6. Sơ đồ luồng kết nối](#6-sơ-đồ-luồng-kết-nối)
- [7. Cài đặt trên Ubuntu 22.04 LTS](#7-cài-đặt-trên-ubuntu-2204-lts)
- [8. Cấu hình Haproxy + iptables](#8-cấu-hình-haproxy--iptables)
- [9. Cấu hình TURN Server (coturn)](#9-cấu-hình-turn-server-coturn)
- [10. Cấu hình Cluster Proxy](#10-cấu-hình-cluster-proxy)
- [11. Kiểm tra & Vận hành](#11-kiểm-tra--vận-hành)
- [12. Tài liệu tham khảo](#12-tài-liệu-tham-khảo)

---

## 1. Tổng quan về BBB 3.0.28

BigBlueButton (BBB) là hệ thống hội nghị truyền hình mã nguồn mở dành cho giáo dục trực tuyến. Phiên bản **3.0.28** là bản phát hành ổn định mới nhất (29/05/2026), chạy trên **Ubuntu 22.04 LTS (Jammy)**, yêu cầu **Docker** cho LibreOffice sandbox.

Greenlight v3 (front-end) được xây dựng trên **Ruby on Rails + React** — xem [GitHub Greenlight](https://github.com/bigbluebutton/greenlight).

---

## 2. Tính năng mới trong 3.0.28

Phiên bản này tập trung vào **Breakout Rooms**, **LiveKit**, **BlockNote (shared notes)**, và **hiệu suất máy chủ**.

### HTML5 Client

| Loại | Tính năng |
|------|-----------|
| **Mới** | LiveKit `forceRelay`/`forceRelayOnFirefox` — ép sử dụng TURN relay |
| **Mới** | Phím tắt Esc để vào/ra khỏi BlockNote shared notes editor |
| **Mới** | Moderator quản lý lock settings trong breakout rooms |
| **Mới** | Recording parameters truyền sang breakout rooms |
| **Cải thiện** | BlockNote: chống crash bảng, toolbar tĩnh, xử lý focus, badge |
| **Cải thiện** | Accessibility: điều hướng bàn phím settings dropdown |
| **Cải thiện** | Hiệu suất video streams trên server |
| **Sửa lỗi** | Preloading slides không hoạt động với proxy |
| **Sửa lỗi** | Talking indicator bị cắt chữ |
| **Sửa lỗi** | Listen-in function bị lỗi breakout room |
| **Sửa lỗi** | Shared-notes CORS dùng `$bbb_cors_origin` |

### Core

| Loại | Tính năng |
|------|-----------|
| **Mới** | Recording parameter passthrough to breakouts |
| **Mới** | Moderator quản lý lock settings breakout + inherit từ parent meeting |
| **Cải thiện** | Session grouping sau khi disconnect |
| **Cải thiện** | Public media groups được tạo lazy |
| **Cải thiện** | GQL-middleware: json patcher dùng LCS move generation |
| **Sửa lỗi** | Presentation file size limits enforced on all paths |
| **Sửa lỗi** | Breakout propagate parent client settings override |

### Recording

| Loại | Tính năng |
|------|-----------|
| **Sửa lỗi** | FFmpeg high memory usage do video PTS gaps |
| **Docs** | Nội bộ: video EDL/layout documentation |

### Packaging & Build

| Loại | Chi tiết |
|------|----------|
| **Dependency** | shared-notes-server thêm postgresql-14 |
| **Playback** | bbb-playback bump lên v5.4.7 |
| **LiveKit** | livekit-cli@2.17.3 |
| **Security** | serialize-javascript 7.0.5, tika 3.3.1, tomcat-embed 10.1.55 |

> **Lưu ý proxy:** Ai dùng BBB sau proxy cần thêm `set $bbb_cors_origin 'https://bbb-proxy.example.com/';` vào `/etc/bigbluebutton/nginx/bbb-cluster.nginx`

---

## 3. So sánh phiên bản 3.0.x

| Tính năng | 3.0.26 | 3.0.27 | 3.0.28 |
|-----------|--------|--------|--------|
| BlockNote (shared notes) | Cơ bản | Export cluster, static toolbar, Ctrl+Z | Badge, focus, CORS cluster |
| Breakout Rooms | — | User ID handling | Lock settings, recording passthrough |
| LiveKit | — | — | forceRelay/forceRelayOnFirefox |
| Infinite whiteboard pan | — | Có | — |
| Callback URL validation | — | Có | — |
| Presentation token auth | — | Có | — |
| Recording ffmpeg memory fix | — | — | Có |
| Plugin manifest cache | — | bbb-web cache | — |
| Performance improvements | — | MediaSenders memoize | Video streams, LCS patcher |
| Accessibility | — | — | Settings dropdown, Esc shortcut |

---

## 4. Yêu cầu hệ thống

### Tối thiểu cho Production

| Thành phần | Yêu cầu |
|------------|---------|
| OS | Ubuntu 22.04 LTS 64-bit (kernel 5.x) |
| Docker | Phiên bản mới nhất |
| RAM | 16 GB (có swap) |
| CPU | 8 cores (single-thread cao) |
| Disk | 500 GB (recording) / 50 GB (không recording) |
| Bandwidth | 250 Mbit/s (symmetrical) |
| Ports | TCP 80, 443; UDP 16384-32768 |
| Hostname | FQDN (VD: bbb.example.com) + SSL certificate |
| IPv6 | Bắt buộc (có thể tắt trong FreeSWITCH nếu cần) |

### Tối thiểu cho Development

| Thành phần | Yêu cầu |
|------------|---------|
| RAM | 8 GB |
| CPU | 4 cores |
| Disk | 50 GB |
| IPv6 | Có thể chỉ IPv4 |

---

## 5. Kiến trúc thiết kế triển khai

### 5.1. Sơ đồ tổng thể (High-Level Architecture)

```
                          Internet
                             |
                      [ Haproxy + iptables ]
                       Layer 4/7 Load Balancer
                      Firewall & SSL Termination
                             |
                  -----------+-----------
                 |                       |
          [ TURN Server ]        [ BBB 3.0.28 Server ]
          (coturn :3478/443)     (nginx :80/443)
                                     |
                    +----------------+----------------+
                    |                |                |
              [nginx reverse proxy]  |        [WebRTC SFU]
                    |                |                |
           +--------+--------+       |        [mediasoup]
           |        |        |       |        [Kurento]
     [HTML5 Client] [API]  [WS]     |                |
           |        |        |       |                |
           +--------+--------+       |                |
                    |                |                |
              [bbb-web (Java/Scala)] |        [FreeSWITCH]
                    |                |           (audio)
                    +--------+-------+
                             |
                       [Redis PubSub]
                             |
              +--------------+--------------+
              |              |              |
        [Akka Apps]   [FS-ESL Akka]   [MongoDB]
        (meeting logic) (FreeSWITCH)  (session state)
              |              |
        [GraphQL Middleware / Server]
              |
        [bbb-pads / Etherpad / BlockNote]
              |
        [bbb-export-annotations]
              |
        [Recording Processor]
```

### 5.2. Kiến trúc triển khai với Haproxy + iptables

```
                            DNS Public
                        ucs1.yourdomain.vn
                     --> 123.234.10.9 (Public IP)
                                |
                      [Firewall Gateway L2/L3]
                        iptables NAT Rules
                        123.234.10.1 (Public)
                                |
                      [Haproxy Layer 4/7]
                        192.168.1.2 (Internal)
                      SSL Termination / Load Balancing
                                |
           +--------------------+--------------------+
           |                                         |
   [BBB 3.0.28 Server]                     [TURN Server]
   192.168.1.13 (Internal)              192.168.1.14 (Internal)
   ucs1.yourdomain.local                turn.yourdomain.local
           |                                         |
    [coturn :3478/443 UDP/TCP]
           |
    [nginx :80/443]
           |
    [bbb-web] [Akka] [HTML5] [FreeSWITCH] [Redis] [MongoDB]
           |
    [Docker - LibreOffice]
```

### 5.3. Thành phần chi tiết

| Thành phần | Công nghệ | Vai trò |
|------------|-----------|---------|
| **Haproxy** | HAProxy 2.x | Load balancer Layer 4/7, SSL termination, CORS |
| **iptables** | Linux netfilter | NAT, port forwarding, firewall rules |
| **nginx** | Nginx | Reverse proxy nội bộ, serve static assets |
| **bbb-web** | Java/Scala | API BigBlueButton, quản lý meeting |
| **Akka Apps** | Scala/Akka | Logic hội họp thời gian thực |
| **HTML5 Client** | React.js + Meteor.js | Giao diện người dùng |
| **HTML5 Server** | Node.js (Meteor) | Backend xử lý WebSocket, DDP |
| **FreeSWITCH** | C | Xử lý âm thanh (VoIP) |
| **mediasoup/Kurento** | C++/JS | WebRTC SFU (video, screenshare) |
| **LiveKit** | Go | WebRTC SFU thế hệ mới (3.0+) |
| **Redis** | Key-value store | PubSub giữa các thành phần, lưu events |
| **MongoDB** | NoSQL | Trạng thái session HTML5 |
| **GraphQL** | Hasura | Middleware/server cho client data |
| **coturn** | C | TURN/STUN server cho WebRTC |
| **Docker** | Container | LibreOffice sandbox |
| **Etherpad/BlockNote** | Node.js | Shared notes cộng tác |

---

## 6. Sơ đồ luồng kết nối

### 6.1. Client kết nối

```
User Browser
     |
     | 1. HTTPS :443
     v
Haproxy (SSL Termination)
     |
     | 2. HTTP proxy_protocol :82
     v
nginx (bigbluebutton site)
     |
     +--> 3.1 HTML5 Client (static files)
     +--> 3.2 /bigbluebutton/api (bbb-web)
     +--> 3.3 WebSocket (Meteor DDP)
     +--> 3.4 /bbb-webrtc-sfu (mediasoup)
     +--> 3.5 /pad (Etherpad/BlockNote)
     +--> 3.6 /graphql (GraphQL)
     +--> 3.7 /livekit (LiveKit)
```

### 6.2. Luồng Audio/Video WebRTC

```
User Browser (WebRTC)
     |
     |-- ICE Candidates:
     |   - Host (trực tiếp)
     |   - STUN (phát hiện NAT)
     |   - TURN (relay qua coturn :443)
     |
     +--> Direct: mediasoup/Kurento (UDP 16384-32768)
     +--> Relay: coturn TURN Server (TCP/UDP 443)
     +--> Audio: FreeSWITCH (SIP/WebRTC)
```

### 6.3. Luồng Recording

```
Meeting Events
     |
     v
Redis DB (lưu events)
     |
     v (kết thúc meeting)
Recording Processor
     |
     +--> ffmpeg (video processing)
     +--> bbb-playback (render)
     +--> bbb-export-annotations (annotations)
     |
     v
Published Recording (playback_host)
```

---

## 7. Cài đặt trên Ubuntu 22.04 LTS

### Bước 1: Chuẩn bị hệ thống

```bash
# Kiểm tra locale
cat /etc/default/locale
# Phải có: LANG="en_US.UTF-8"

# Nếu chưa có:
sudo apt-get install -y language-pack-en
sudo update-locale LANG=en_US.UTF-8
# Logout & login lại

# Kiểm tra system locale
sudo systemctl show-environment
# Phải có: LANG=en_US.UTF-8

# Kiểm tra thông số máy chủ
free -h                # RAM >= 16G (production) / 8G (dev)
cat /etc/lsb-release   # Ubuntu 22.04
uname -m               # x86_64
uname -r               # kernel 5.x
grep -c ^processor /proc/cpuinfo   # >= 8 cores
ip addr | grep inet6   # IPv6 support
```

### Bước 2: Mở firewall

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 16384:32768/udp
sudo ufw enable
```

### Bước 3: Cài đặt BBB 3.0.28

Sử dụng script `bbb-install.sh` từ nhánh `v3.0.x-release`:

```bash
# Tải script
wget -qO- https://raw.githubusercontent.com/bigbluebutton/bbb-install/v3.0.x-release/bbb-install.sh

# Cài đặt với hostname và email (Let's Encrypt SSL)
sudo bash bbb-install.sh -v jammy-300 -s bbb.example.com -e admin@example.com

# Cài đặt cụ thể phiên bản 3.0.28
sudo bash bbb-install.sh -v jammy-300-3.0.28 -s bbb.example.com -e admin@example.com

# Cài đặt kèm Greenlight
sudo bash bbb-install.sh -v jammy-300 -s bbb.example.com -e admin@example.com -g

# Cài đặt kèm Greenlight + SSL tự ký
sudo bash bbb-install.sh -v jammy-300 -s bbb.example.com -e admin@example.com -g -w
```

> **Lưu ý quan trọng:**
> - HOSTNAME phải là FQDN (VD: `bbb.example.com`)
> - Port 80/443 không được dùng bởi dịch vụ khác
> - Server phải là máy **sạch**, không có Apache/Nginx trước

### Bước 4: Script tự động hóa (UCS) — phiên bản 3.0.28

Script đã được cập nhật cho Ubuntu 22.04 LTS và BBB 3.0.28, lưu tại thư mục `3.0.28/`:

```bash
# Bước 1: Fix Ubuntu + cài tools (Docker, xrdp, firewall)
sudo bash s1_fix_ubuntu.sh

# Bước 2: Cài BBB 3.0.28 (hỏi FQDN, email SSL, chọn phiên bản)
sudo bash s2_setup_bbb.sh
```

Hoặc tải trực tiếp từ GitHub:

```bash
# Bước 1
wget https://raw.githubusercontent.com/PhDLeToanThang/ucs/master/3.0.28/s1_fix_ubuntu.sh
sudo bash s1_fix_ubuntu.sh

# Bước 2
wget https://raw.githubusercontent.com/PhDLeToanThang/ucs/master/3.0.28/s2_setup_bbb.sh
sudo bash s2_setup_bbb.sh
```

> **So với phiên bản cũ:**
> - `s1_fix_ubuntu.sh`: Thêm Docker Compose plugin, tối ưu firewall, bỏ ubuntu-desktop (quá nặng)
> - `s2_setup_bbb.sh`: Hỗ trợ chọn phiên bản (`jammy-300` mới nhất hoặc `jammy-300-3.0.28` cụ thể), hỏi cài Greenlight/TURN, kiểm tra sau cài
> - `uninstall_bbb.sh`: Hỗ trợ BBB 3.0 (GraphQL services, pads), sửa lỗi đường dẫn `bionic` → `jammy`

### Bước 5: Kiểm tra cài đặt

```bash
# Kiểm tra tổng thể
sudo bbb-conf --check

# Kiểm tra trạng thái services
sudo bbb-conf --status

# Kiểm tra danh sách gói
dpkg -l | grep bbb-

# Lấy URL và Secret
sudo bbb-conf --secret
```

**Output mong đợi (`bbb-conf --status`):**

```
nginx ————————————————————————————————► [✔ - active]
freeswitch ———————————————————————————► [✔ - active]
redis-server —————————————————————————► [✔ - active]
bbb-apps-akka ————————————————————————► [✔ - active]
bbb-fsesl-akka ———————————————————————► [✔ - active]
bbb-graphql-actions ——————————————————► [✔ - active]
bbb-graphql-middleware ———————————————► [✔ - active]
bbb-graphql-server ———————————————————► [✔ - active]
bbb-webrtc-sfu ———————————————————————► [✔ - active]
bbb-webrtc-recorder ——————————————————► [✔ - active]
etherpad —————————————————————————————► [✔ - active]
bbb-web ——————————————————————————————► [✔ - active]
bbb-pads —————————————————————————————► [✔ - active]
bbb-export-annotations ———————————————► [✔ - active]
bbb-rap-caption-inbox ————————————————► [✔ - active]
bbb-rap-resque-worker ————————————————► [✔ - active]
bbb-rap-starter ——————————————————————► [✔ - active]
```

### Nâng cấp từ 3.0.x

```bash
# Chạy lại script với phiên bản mới nhất
sudo bash bbb-install.sh -v jammy-300 -s bbb.example.com -e admin@example.com

# Nếu gặp lỗi cấu hình bbb-graphql-server:
cd /etc/default
sudo mv bbb-graphql-server.dpkg-dist bbb-graphql-server
sudo bbb-conf --restart
```

> **Nâng cấp từ 2.6/2.7:** Khuyến nghị cài mới Ubuntu 22.04 + BBB 3.0, sau đó copy recordings từ server cũ.

---

## 8. Cấu hình Haproxy + iptables

### 8.1. Mô hình triển khai

```
[Internet] --> [Haproxy :443] --> [iptables NAT] --> [BBB :80 :443]
                                  [BBB Internal : 192.168.1.13]
                                  [TURN Internal : 192.168.1.14]
```

### 8.2. Cấu hình Haproxy (/etc/haproxy/haproxy.cfg)

```cfg
global
    log /dev/log local0
    maxconn 4096
    user haproxy
    group haproxy
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
    ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11

defaults
    log global
    mode tcp
    option tcplog
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

# Frontend HTTPS - SSL Termination
frontend bbb_https
    bind *:443 ssl crt /etc/ssl/certs/bbb.pem
    mode tcp
    option tcplog

    # Phân loại traffic dựa trên SNI
    use_backend bbb_cluster if { ssl_fc_sni -i bbb.example.com }
    use_backend turn_server if { ssl_fc_sni -i turn.example.com }

    default_backend bbb_cluster

# Backend BBB Server
backend bbb_cluster
    mode tcp
    balance leastconn
    option tcp-check
    server bbb1 192.168.1.13:443 check inter 5s fall 3 rise 2

# Backend TURN Server
backend turn_server
    mode tcp
    balance leastconn
    server turn1 192.168.1.14:443 check inter 5s fall 3 rise 2

# Frontend UDP cho WebRTC (TURN)
frontend bbb_udp
    bind *:16384-32768
    mode tcp
    use_backend bbb_udp_servers

backend bbb_udp_servers
    mode tcp
    server bbb1 192.168.1.13 check
```

### 8.3. Cấu hình iptables (NAT + Forwarding)

```bash
# NAT - DNAT cho traffic từ Haproxy đến BBB
iptables -t nat -A PREROUTING -p tcp --dport 443 -d 123.234.10.9 -j DNAT --to-destination 192.168.1.13:443
iptables -t nat -A PREROUTING -p tcp --dport 80 -d 123.234.10.9 -j DNAT --to-destination 192.168.1.13:80
iptables -t nat -A PREROUTING -p udp --dport 16384:32768 -j DNAT --to-destination 192.168.1.13
iptables -t nat -A PREROUTING -p udp --dport 3478 -d 123.234.10.9 -j DNAT --to-destination 192.168.1.14
iptables -t nat -A PREROUTING -p tcp --dport 3478 -d 123.234.10.9 -j DNAT --to-destination 192.168.1.14
iptables -t nat -A PREROUTING -p udp --dport 443 -d 123.234.10.9 -j DNAT --to-destination 192.168.1.14

# MASQUERADE (SNAT)
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# FORWARD rules
iptables -A FORWARD -p tcp -d 192.168.1.13 --dport 443 -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.1.13 --dport 80 -j ACCEPT
iptables -A FORWARD -p udp -d 192.168.1.13 --dport 16384:32768 -j ACCEPT
iptables -A FORWARD -d 192.168.1.14 -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Lưu rules
iptables-save > /etc/iptables/rules.v4
```

### 8.4. Cấu hình BBB cluster proxy (nginx)

Tạo file `/etc/bigbluebutton/nginx/bbb-cluster.nginx`:

```nginx
set $bbb_cors_origin 'https://bbb-proxy.example.com';

location /html5client {
    gzip_static on;
    alias /usr/share/bigbluebutton/html5-client/;
    index index.html;
    try_files $uri $uri/ =404;
}

location /html5client/locales {
    alias /usr/share/bigbluebutton/html5-client/locales;
    autoindex on;
    autoindex_format json;
}
```

Thêm vào `/etc/bigbluebutton/bbb-web.properties`:

```properties
defaultHTML5ClientUrl=https://bbb-proxy.example.com/html5client
presentationBaseURL=https://bbb-01.example.com/bigbluebutton/presentation
accessControlAllowOrigin=https://bbb-proxy.example.com
graphqlWebsocketUrl=wss://bbb-01.example.com/graphql
graphqlApiUrl=https://bbb-01.example.com/api/rest
```

---

## 9. Cấu hình TURN Server (coturn)

### 9.1. Cài đặt coturn

```bash
sudo apt-get update
sudo apt-get install -y coturn
```

### 9.2. Cấu hình coturn (/etc/turnserver.conf)

```conf
listening-port=3478
tls-listening-port=443
listening-ip=<PUBLIC_IP>
relay-ip=<PUBLIC_IP>
min-port=32769
max-port=65535
fingerprint
lt-cred-mech
use-auth-secret
static-auth-secret=<openssl rand -hex 16>
realm=<your-turn-domain>
cert=/etc/turnserver/fullchain.pem
pkey=/etc/turnserver/privkey.pem
cipher-list="ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
no-loopback-peers
no-multicast-peers
```

### 9.3. SSL cho TURN

```bash
sudo certbot certonly --standalone -d turn.example.com
sudo mkdir -p /etc/turnserver
# Copy certificates
sudo cp /etc/letsencrypt/live/turn.example.com/fullchain.pem /etc/turnserver/
sudo cp /etc/letsencrypt/live/turn.example.com/privkey.pem /etc/turnserver/
# Auto-renew hook
sudo mkdir -p /etc/letsencrypt/renewal-hooks/deploy
# Tạo script renew hook
```

### 9.4. Cấu hình BBB dùng TURN

Edit `/etc/bigbluebutton/turn-stun-servers.xml`:

```xml
<bean id="stun0" class="org.bigbluebutton.web.services.turn.StunServer">
    <constructor-arg index="0" value="stun:turn.example.com"/>
</bean>
<bean id="turn0" class="org.bigbluebutton.web.services.turn.TurnServer">
    <constructor-arg index="0" value="<secret_value>"/>
    <constructor-arg index="1" value="turns:turn.example.com:443?transport=tcp"/>
    <constructor-arg index="2" value="86400"/>
</bean>
<bean id="turn1" class="org.bigbluebutton.web.services.turn.TurnServer">
    <constructor-arg index="0" value="<secret_value>"/>
    <constructor-arg index="1" value="turn:turn.example.com:443?transport=tcp"/>
    <constructor-arg index="2" value="86400"/>
</bean>
```

```bash
sudo systemctl restart coturn
sudo bbb-conf --restart
```

---

## 10. Cấu hình Cluster Proxy

Khi triển khai nhiều BBB servers đằng sau một proxy chung (Scalelite), cấu hình:

### Trên Proxy Server (nginx)

```nginx
location /bbb-01/html5client/ {
    proxy_pass https://bbb-01.example.com/bbb-01/html5client/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
}

location /bbb-01/bigbluebutton/api {
    proxy_pass https://bbb-01.example.com/bigbluebutton/api;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
}
```

Lặp lại cho mỗi node BBB.

### Trên mỗi BBB Server

Tạo `/etc/bigbluebutton/nginx/bbb-cluster.nginx`:

```nginx
set $bbb_cors_origin 'https://bbb-proxy.example.com';

location /bbb-01/html5client {
    gzip_static on;
    alias /usr/share/bigbluebutton/html5-client/;
    index index.html;
    try_files $uri $uri/ =404;
}
```

**Lưu ý:** Xem [Cluster Proxy docs](https://docs.bigbluebutton.org/administration/cluster-proxy/) cho cấu hình đầy đủ (bbb-web.properties, bbb-html5.yml, graphql, etherpad.json, systemd override, v.v.)

---

## 11. Kiểm tra & Vận hành

### 11.1. Kiểm tra hệ thống

```bash
# Kiểm tra tổng thể
sudo bbb-conf --check

# Kiểm tra services
sudo bbb-conf --status

# Restart toàn bộ
sudo bbb-conf --restart

# Debug
sudo bbb-conf --debug
```

### 11.2. Monitoring

Theo dõi log:

```bash
tail -f /var/log/nginx/access.log
tail -f /var/log/bigbluebutton/bbb-web.log
journalctl -f -u bbb-webrtc-sfu
```

### 11.3. Kiểm tra TURN Server

```bash
# Kiểm tra coturn hoạt động
sudo systemctl status coturn
sudo netstat -antp | grep 443

# Kiểm tra STUN
sudo apt-get install -y stuntman-client
stunclient --mode full --localport 30000 turn.example.com 3478

# Test TURN trên trình duyệt
# Mở https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/
# URI: turn:turn.example.com:443
```

### 11.4. Kiểm tra WebRTC với FireFox

```
1. Mở about:config
2. Tìm media.peerconnection.ice.relay_only
3. Set = true (chỉ dùng TURN)
4. Join phòng họp, share webcam
5. Kiểm tra about:webrtc -> ICE Stats -> (relay-tcp)
```

---

## 12. Tài liệu tham khảo

| Nội dung | Link |
|----------|------|
| BBB 3.0 New Features | https://docs.bigbluebutton.org/3.0/new-features |
| Installation Guide | https://docs.bigbluebutton.org/administration/install/ |
| TURN Server | https://docs.bigbluebutton.org/administration/turn-server/ |
| Cluster Proxy | https://docs.bigbluebutton.org/administration/cluster-proxy/ |
| Firewall Config | https://docs.bigbluebutton.org/administration/firewall-configuration/ |
| Server Customization | https://docs.bigbluebutton.org/administration/customize/ |
| GitHub Releases | https://github.com/bigbluebutton/bigbluebutton/releases |
| bbb-install.sh | https://github.com/bigbluebutton/bbb-install |
| Greenlight | https://github.com/bigbluebutton/greenlight |
| UCS Deployment (tác giả) | https://github.com/PhDLeToanThang/ucs/tree/master/3.0 |
| API-Mate | https://mconf.github.io/api-mate/ |
| Demo Server | https://demo.bigbluebutton.org |
| SSL Test | https://www.ssllabs.com/ssltest/ |

---

*Tài liệu biên soạn dựa trên nguồn chính thức từ BigBlueButton Inc. và kinh nghiệm triển khai UCS On-prem / Private Cloud Services.*
