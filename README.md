# Phần 1: Thực hiện triển khai xây dựng UCs - Recording Video, Translate, Subtitle, Whiteboard replay timeline:

****DEPLOY INSTALL a IT UCS SERVER + a Turn Recording Vioce Video Media Server****

- Phiên bản 2024: 2.7.7:

Bước 1: Sửa và cài các tools cho Ubuntu có giao diện và xrdp remote 3389:

wget https://raw.githubusercontent.com/PhDLeToanThang/ucs/master/2.7.7/s1_fix_ubuntu.sh && sudo bash s1_fix_ubuntu.sh

**Lưu ý:** Đây là bản cài DNS Public và On-prem nên trước khi triển khai UCs này bạn phải quản lý được
- DNS public (thuê tên miền và Quản lý các bản ghi public).
- DNS Local (Quản trị DNS Server và FWGW / Haproxy Local).
- Nếu có Haproxy / LBN người Quản trị sẽ cấu hình Config của LBN/ Haproxy cho phép Proxy hoặc NAT Forward từ Firewall.

***Ví dụ:***

DNS public:  
   ucs1.yourdomain.vn --> ipv4 public: 123.234.10.9   ---> IPv4 public: FIrewall Gateway L2/L3 :   123.234.10.1 ---> IPV4 local của LBN/Haproxy: 192.168.1.2

DNS Local:
    DNS Server Local ---> Ipv4 DNS Local: 192.168.1.20 ---> IPv4 DNS A (host): ucs1.yourdomain.local: 192.168.1.13 ---> 

Bước 2: Cài Các thư viện cho Big Blue Button (2.7.7):

wget https://raw.githubusercontent.com/PhDLeToanThang/ucs/master/2.7.7/s2_setup_bbb.sh && sudo bash s2_setup_bbb.sh 

