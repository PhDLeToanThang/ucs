# Phần 1: Thực hiện triển khai xây dựng UCs - Recording Video, Translate, Subtitle, Whiteboard replay timeline:

****DEPLOY INSTALL a IT UCS SERVER + a Turn Recording Vioce Video Media Server****

- Phiên bản mới 2024: 2.7.11 (update 6.2024): Tham khảo:  https://docs.bigbluebutton.org/new-features/

**Lưu ý: Note that BigBlueButton 2.7.11 runs on Ubuntu Focal (20.04)**

- Phiên bản 2024: 2.7.7 (old):

## Yêu cầu:

- Máy chủ Ubuntu linux version 20.04 LTS,
- Có quản lý DNS public và kiểm soát các Firewall Gateway, Haproxy Layer 3,4,7.
- Hoạt động quản lý và vận hành dưới tên miền public, có HTTPs port 80,443. 

Bước 1: Sửa và cài các tools cho Ubuntu có giao diện và xrdp remote 3389:

wget https://raw.githubusercontent.com/PhDLeToanThang/ucs/master/2.7.11/s1_fix_ubuntu.sh && sudo bash s1_fix_ubuntu.sh

**Lưu ý:** Đây là bản cài DNS Public và On-prem nên trước khi triển khai UCs này bạn phải quản lý được.
- Ubuntu linux 20.04 LTS cần cài dạng Ubuntu Server, nếu cài Ubuntu minimum sẽ cần cài bổ sung: Dockers hoặc Containers)
- Gói cài BBB 2.7.11 hiện này chỉ support Ubuntu 20.04 LTS.
- DNS public (thuê tên miền và Quản lý các bản ghi public).
- DNS Local (Quản trị DNS Server và FWGW / Haproxy Local).
- Nếu có Haproxy / LBN người Quản trị sẽ cấu hình Config của LBN/ Haproxy cho phép Proxy hoặc NAT Forward từ Firewall.

***Ví dụ:***

DNS public:  
   ucs1.yourdomain.vn --> ipv4 public: 123.234.10.9 (External)  ---> IPv4 public: FIrewall Gateway L2/L3 :   123.234.10.1 ---> IPV4 local của LBN/Haproxy: 192.168.1.2 (internal API Gateway)

DNS Local:
    DNS Server Local ---> Ipv4 DNS Local: 192.168.1.20 (iPAM/AD-DC Platform) ---> IPv4 DNS A (host): ucs1.yourdomain.local: 192.168.1.13 (Your UCs Server)---> 

Bước 2: Cài Các thư viện cho Big Blue Button (2.7.11):

wget https://raw.githubusercontent.com/PhDLeToanThang/ucs/master/2.7.11/s2_setup_bbb.sh && sudo bash s2_setup_bbb.sh 

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

4.1.4.1. Máy chủ HTML5 được xây dựng dựa trên.

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

#### Giao diện người dùng ```FRONTEND(s)```:

- Nhận sự kiện ```ValidateAuthTokenResp``` để hoàn tất xác thực.
- Đăng ký và xuất bản bộ sưu tập.
- Các sự kiện DDP khác bao gồm các lệnh gọi phương thức để gửi sự kiện đến ứng dụng ```akka-apps```.
- Xử lý hoàn toàn các sự kiện redis của Streamer: Con trỏ, Chú thích, Chia sẻ video bên ngoài.
- Vẫn yêu cầu các sự kiện ```MeetStarted``` và ```MeetEnded``` để tạo/hủy hàng đợi xử lý sự kiện trong mỗi cuộc họp.

#### Phần phụ trợ ```BACKEND(s)```:

- Xử lý tất cả các sự kiện không phải của người phát trực tuyến.
- Nếu có nhiều hơn một chương trình phụ trợ đang chạy, bbb-web sẽ phân chia tải theo kiểu vòng tròn bằng cách chỉ định một ```instanceId```.
Vì vậy, các chương trình phụ trợ riêng lẻ chỉ xử lý các sự kiện redis cho các cuộc họp khớp với ```instanceId``` được liên kết
```ValidateAuthTokenResp``` cũng được chuyển đến các chương trình phụ trợ, điều này cần thiết cho các trường hợp bạn chỉ có chương trình phụ trợ, không có giao diện người dùng
- Ví dụ như môi trường nhà phát triển không cần quan tâm đến việc mở rộng quy mô.

- Khi bạn sử dụng sudo ```bbb-conf --setip <hostname>``` hoặc ```sudo bbb-conf --restart```, ```bbb-conf``` sẽ chạy ```/etc/bigbluebutton/bbb-conf/apply-config.sh``` giữa lúc tắt máy và khởi động lại quy trình BigBlueButton. Bằng cách này, bạn có thể thay đổi giá trị cấu hình của BigBlueButton hoặc sử dụng một số hàm trợ giúp trong ```apply-lib.sh```. Xem Tự động áp dụng các thay đổi cấu hình khi khởi động lại.

##### web BBB

- Ứng dụng web BigBlueButton là một ứng dụng dựa trên Java được viết bằng Scala. Nó triển khai API BigBlueButton và giữ bản sao trạng thái cuộc họp.

- API BigBlueButton cung cấp sự tích hợp của bên thứ ba (chẳng hạn như plugin BigBlueButtonBN cho Moodle) với điểm cuối để kiểm soát máy chủ BigBlueButton.

- Mọi quyền truy cập vào BigBlueButton đều thông qua một cổng giao diện người dùng (chúng tôi gọi là ứng dụng của bên thứ ba).
- BigBlueButton tích hợp Moodle, Wordpress, Canvas, Sakai, Matter Most và các phần mềm khác (xem phần tích hợp của bên thứ ba).
- BigBlueButton đi kèm với giao diện người dùng riêng có tên Greenlight.
- Khi sử dụng hệ thống quản lý học tập (LMS) như Moodle, giáo viên có thể thiết lập các phòng BigBlueButton trong khóa học của mình và sinh viên có thể truy cập vào các phòng cũng như bản ghi âm của họ.

##### Redis PubSub

- Redis PubSub cung cấp kênh liên lạc giữa các ứng dụng khác nhau chạy trên máy chủ BigBlueButton.

##### Redis DB

- Khi một cuộc họp được ghi lại, tất cả các sự kiện sẽ được lưu trữ trong Redis DB. Khi cuộc họp kết thúc, Bộ xử lý ghi sẽ lấy tất cả các sự kiện đã ghi cũng như các tệp thô (PDF, WAV, FLV) khác nhau để xử lý.
  
- BigBlueButton đi kèm với một số bản demo API đơn giản. Bất kể bạn sử dụng giao diện người dùng nào, tất cả đều sử dụng API cơ bản.

##### Ứng dụng akka

- Ứng dụng BigBlueButton là ứng dụng chính tập hợp các ứng dụng khác nhau để mang đến sự cộng tác theo thời gian thực trong cuộc họp. Nó cung cấp danh sách người dùng, trò chuyện, bảng trắng, bài thuyết trình trong cuộc họp.

Dưới đây là sơ đồ về các thành phần khác nhau của Apps Akka:

![image](https://github.com/PhDLeToanThang/ucs/assets/106635733/532fe332-7064-42f2-b880-ab2ecb8d974c)

_Kiến trúc ứng dụng Akka_

Logic nghiệp vụ của cuộc họp nằm trong MeetActor. Đây là nơi lưu trữ thông tin về cuộc họp và là nơi xử lý tất cả tin nhắn cho cuộc họp.

##### FSESL hay còn gọi là FSESL

Chúng tôi đã trích xuất thành phần tích hợp với FreeSWITCH vào ứng dụng riêng của nó. 
Điều này cho phép những người khác đang sử dụng hệ thống hội nghị thoại ngoài FreeSWITCH dễ dàng tạo sự tích hợp của riêng họ.
Giao tiếp giữa các ứng dụng và Lớp cổng sự kiện FreeSWITCH (fsels) sử dụng tin nhắn thông qua redis pubsub.

![image](https://github.com/PhDLeToanThang/ucs/assets/106635733/89b2d1c7-5b9e-442c-81fa-46e842005b33)

_Kiến trúc FsESL Akka_

##### FreeSWITCH

Chúng tôi cho rằng FreeSWITCH là một phần mềm tuyệt vời để xử lý âm thanh.

FreeSWITCH cung cấp khả năng hội nghị thoại trong BigBlueButton. Người dùng có thể tham gia hội nghị thoại thông qua tai nghe. Người dùng tham gia thông qua Google Chrome hoặc Mozilla Firefox có thể tận dụng âm thanh chất lượng cao hơn bằng cách kết nối bằng WebRTC. FreeSWITCH cũng có thể được tích hợp với các nhà cung cấp VOIP để những người dùng không thể tham gia bằng tai nghe vẫn có thể gọi bằng điện thoại của họ.

##### Kurento và WebRTC-SFU

Kurento Media Server KMS là một media server triển khai cả mô hình SFU và MCU. KMS chịu trách nhiệm phát trực tuyến webcam, âm thanh chỉ nghe và chia sẻ màn hình. WebRTC-SFU đóng vai trò là bộ điều khiển phương tiện xử lý các cuộc đàm phán và quản lý các luồng phương tiện.

##### Tham gia hội nghị bằng giọng nói

Người dùng có thể tham gia hội nghị thoại (chạy trong FreeSWITCH) từ ứng dụng khách BigBlueButton HTML5 hoặc qua điện thoại. 
Khi tham gia thông qua ứng dụng khách, người dùng có thể chọn tham gia Micrô hoặc Chỉ nghe và ứng dụng khách BigBlueButton sẽ thực hiện kết nối âm thanh với máy chủ thông qua WebRTC. WebRTC cung cấp cho người dùng âm thanh chất lượng cao với độ trễ thấp hơn.

![image](https://github.com/PhDLeToanThang/ucs/assets/106635733/9d443239-6f77-4329-8579-3a2295be9e2b)

##### Tải lên bản trình bày

Các bản trình bày đã tải lên sẽ trải qua quá trình chuyển đổi để được hiển thị bên trong ứng dụng khách. Khi bản trình bày được tải lên là tài liệu Office, nó cần được chuyển đổi thành PDF bằng LibreOffice. Tài liệu PDF sau đó được chuyển đổi thành đồ họa vector có thể mở rộng (SVG) thông qua bbb-web.

![image](https://github.com/PhDLeToanThang/ucs/assets/106635733/408b6e44-d95b-408c-aa4d-8b93d44a7156)

_Quá trình chuyển đổi sẽ gửi thông báo tiến trình tới máy khách thông qua Redis pubsub_

##### Luồng chuyển đổi bản trình bày

Sơ đồ bên dưới mô tả luồng chuyển đổi bản trình bày. 
Chúng tôi xem xét cấu hình để bật và tắt chuyển đổi SWF, SVG và PNG.

![Luồng chuyển đổi chung](/img/diagrams/Presentation Conversion Diagram-General Conversion Flow.png)

Sau đó bên dưới luồng chuyển đổi SVG. Nó bao gồm dự phòng chuyển đổi. Đôi khi, chúng tôi phát hiện thấy trình duyệt tải nặng tệp SVG được tạo, chúng tôi sử dụng dự phòng để đặt hình ảnh đã được phân loại vào bên trong tệp SVG và làm cho trình duyệt tải nhẹ.

![Luồng chuyển đổi SVG](/img/diagrams/Presentation Conversion Diagram-SVG Conversion Flow.png)

Tham khảo tài liệu: https://docs.bigbluebutton.org/ 


# Phần 3: Lợi ích ứng dụng UCs kiểu On-prem thành Private Cloud Services:

1. BBB có thể tích hợp với Moodle để quản lý và tương tác nội dung dạy học:
2.     Trên LMS (Quản lý khoá học)  vs
3.     LCMS (Quản lý nội dung số).
4.     Quản lý đầu sách, file điện tử của Giảng viên, tác giả soạn tài liệu cá nhân trên máy cá nhân.
5.     Quản lý đầu sách, file điện tử của nhóm Giảng viên, nhóm tác giả soạn tài liệu sau khi đã hiệu đính, chỉnh duyệt lưu trên máy chủ của Nhà Trường/ Tỏ chức phòng ban.
6.     Quản lý đầu sách, files điện tử đã được Ban lãnh đạo Nhà Trường học cấp Trưởng Khoa/Phó khoa duyệt lưu trên hệ thống do Thủ Thư Quản lý Thư viện phụ trách máy chủ WWeb Calibre.
7.     Các bộ phận như Kinh Doanh, Thủ Thư, Luật sư quản lý Xuất bản sách, Kế Toán quản lý Chi phí - Doanh thu - Tồn kho và báo cáo kết quả Kinh Doanh sách số của Nhà Trường / Doanh nghiệp phối hợp Quản lý sách số trên Cổng Thương mại điện tử Kinh Doanh sách số.
8.    Tích hợp với ITSAM giúp Chat, Bot, AI Chat, chuyển đổi Ticket để hỗ trợ Khách hàng thuê dịch vụ hoặc giúp đội Chăm sóc khách hàng dịch vụ thu nhận thông tin hỗ trợ.

![image](https://github.com/PhDLeToanThang/ucs/assets/106635733/fc577f0f-8ef4-4107-b9f5-b54f2ce1b269)
