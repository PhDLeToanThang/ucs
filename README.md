# Phần 1: Thực hiện triển khai xây dựng UCs - Recording Video, Translate, Subtitle, Whiteboard replay timeline:

****DEPLOY INSTALL a IT UCS SERVER + a Turn Recording Vioce Video Media Server****

- Phiên bản 2024: 2.7.7:

Bước 1: Sửa và cài các tools cho Ubuntu có giao diện và xrdp remote 3389:

wget https://raw.githubusercontent.com/PhDLeToanThang/ucs/master/2.7.7/s1_fix_ubuntu.sh && sudo bash s1_fix_ubuntu.sh

**Lưu ý:** Đây là bản cài DNS Public và On-prem nên trước khi triển khai UCs này bạn phải quản lý được.
- Ubuntu linux 20.04 LTS cần cài dạng Ubuntu Server, nếu cài Ubuntu minimum sẽ cần cài bổ sung: Dockers hoặc Containers)
- Gói cài BBB 2.7.7 hiện này chỉ support Ubuntu 20.04 LTS.
- DNS public (thuê tên miền và Quản lý các bản ghi public).
- DNS Local (Quản trị DNS Server và FWGW / Haproxy Local).
- Nếu có Haproxy / LBN người Quản trị sẽ cấu hình Config của LBN/ Haproxy cho phép Proxy hoặc NAT Forward từ Firewall.

***Ví dụ:***

DNS public:  
   ucs1.yourdomain.vn --> ipv4 public: 123.234.10.9 (External)  ---> IPv4 public: FIrewall Gateway L2/L3 :   123.234.10.1 ---> IPV4 local của LBN/Haproxy: 192.168.1.2 (internal API Gateway)

DNS Local:
    DNS Server Local ---> Ipv4 DNS Local: 192.168.1.20 (iPAM/AD-DC Platform) ---> IPv4 DNS A (host): ucs1.yourdomain.local: 192.168.1.13 (Your UCs Server)---> 

Bước 2: Cài Các thư viện cho Big Blue Button (2.7.7):

wget https://raw.githubusercontent.com/PhDLeToanThang/ucs/master/2.7.7/s2_setup_bbb.sh && sudo bash s2_setup_bbb.sh 

# Phần 2. Kiến trúc hạ tầng - Kết nối - Chuyển đổi nội dung số:

## Kết nối mạng nội bộ:

Sơ đồ sau đây cho thấy cách các thành phần khác nhau của BigBlueButton kết nối với nhau thông qua ổ cắm

![image](https://github.com/PhDLeToanThang/ucs/assets/106635733/f240e5a9-d6d6-4ce9-9d63-1d9026e6f0f8)

Trong đó thì có Kiến trúc Cấp cao nhất:

### Kiến trúc cấp cao:

Sơ đồ sau đây cung cấp cái nhìn cấp cao về cách các thành phần của BigBlueButton hoạt động cùng nhau.

![image](https://github.com/PhDLeToanThang/ucs/assets/106635733/a3793811-4c76-4b08-9e0e-9cf909ab610d)

#### Kiến trúc chi tiết chia nhỏ của Từng thành phần phía trong:

#### 4.1. HTML5 client

Máy khách HTML5 là một trang duy nhất, ứng dụng web đáp ứng được xây dựng dựa trên các thành phần sau:

4.1.1. React.js để hiển thị giao diện người dùng một cách hiệu quả

4.1.2. WebRTC để gửi/nhận âm thanh và video

4.1.3. Máy khách HTML5 kết nối trực tiếp với máy chủ BigBlueButton qua cổng 443 (SSL), từ việc tải ứng dụng khách BigBlueButton đến tạo kết nối ổ cắm web. Các kết nối này đều được xử lý bởi nginx.

4.1.4. Máy chủ HTML5 nằm phía sau nginx.

4.1.4.1. Máy chủ HTML5 được xây dựng dựa trên

4.1.4.2. Meteor.js trong ECMA2015 để liên lạc giữa máy khách và máy chủ.

4.1.4.3. MongoDB để giữ trạng thái của từng máy khách BigBlueButton nhất quán với máy chủ BigBlueButton

Cơ sở dữ liệu MongoDB chứa thông tin về tất cả các cuộc họp trên máy chủ và lần lượt từng máy khách được kết nối với một cuộc họp. Mỗi khách hàng của người dùng chỉ biết trạng thái cuộc họp của họ, chẳng hạn như tin nhắn trò chuyện công khai và riêng tư được gửi và nhận của người dùng. Phía máy khách đăng ký các bộ sưu tập đã xuất bản ở phía máy chủ. Các bản cập nhật lên MongoDB ở phía máy chủ sẽ tự động được đẩy lên MiniMongo ở phía máy khách.

Sơ đồ sau đây cung cấp thông tin tổng quan về kiến trúc của máy khách HTML5 và hoạt động giao tiếp của nó với các thành phần khác trong BigBlueButton.

![image](https://github.com/PhDLeToanThang/ucs/assets/106635733/a0698fb2-d083-4b2f-a9ae-e7a157651193)

#### Khả năng mở rộng của thành phần máy chủ HTML5:

- BigBlueButton 2.2 đã sử dụng một quy trình nodejs duy nhất cho tất cả giao tiếp phía máy khách. Quá trình này sẽ bắt đầu tắc nghẽn (quy trình nodejs, chạy trên một lõi CPU, bắt đầu sử dụng 100% lõi). Bởi vì nodejs đang chạy trên một lõi CPU nên việc có máy chủ lõi CPU 16 hoặc 32 cho BigBlueButton 2.2 không mang lại nhiều khả năng mở rộng bổ sung.

- BigBlueButton 2.3 chuyển từ quy trình nodejs duy nhất cho bbb-html5 sang nhiều quy trình nodejs xử lý tin nhắn đến từ máy khách. Điều này có nghĩa là bbb-html5 có thể sử dụng nhiều lõi CPU để xử lý thông báo và xử lý các phiên trình duyệt (mỗi quy trình nodejs chạy trên một lõi CPU duy nhất).

- Kể từ 2.3-alpha-7, bbb-html5 sử dụng 2 quy trình "frontend" và hai "backend" (giá trị này có thể định cấu hình trong bbb-html5-with-roles.conf, xem Tệp cấu hình). Cần phải khởi động lại BigBlueButton nếu bạn thực hiện thay đổi đối với các tệp này.

- Sự phân tích chức năng giữa front-end và back-end như sau:

#### Giao diện người dùng ```FRONTEND(s)``` :

- Nhận sự kiện ```ValidateAuthTokenResp``` để hoàn tất xác thực.
- Đăng ký và xuất bản bộ sưu tập.
- Các sự kiện DDP khác bao gồm các lệnh gọi phương thức để gửi sự kiện đến ứng dụng ```akka-apps```.
- Xử lý hoàn toàn các sự kiện redis của Streamer: Con trỏ, Chú thích, Chia sẻ video bên ngoài.
- Vẫn yêu cầu các sự kiện ```MeetStarted``` và ```MeetEnded``` để tạo/hủy hàng đợi xử lý sự kiện trong mỗi cuộc họp.

