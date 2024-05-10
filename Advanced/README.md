# Phần 1: Thực hiện triển khai xây dựng ITSM - ITIL Helpdesk Server:

****DEPLOY INSTALL A ITIL - ITSM - HELPDESK - IT ASSETS SERVER:****
- Phiên bản mới nhất April.2024: 10.0.15:
  
wget https://raw.githubusercontent.com/PhDLeToanThang/itil-helpdesk/master/Advanced/deploy_itsm_v10015.sh && sudo bash deploy_itsm_v10015.sh

****Tóm tắt Dưới đây là danh sách các vấn đề bảo mật đã được khắc phục trong phiên bản sửa lỗi 10.0.15 này:****

- Lỗ hổng SQL injection từ tìm kiếm bản đồ khi đã đăng nhập (CVE-2024-31456)
- Lỗ hổng chiếm đoạt tài khoản thông qua SQL Injection trong tính năng tìm kiếm đã lưu (CVE-2024-29889)
Ngoài ra, đây là danh sách ngắn các thay đổi chính được thực hiện trong phiên bản này:
- Khắc phục quyền sử dụng bởi biểu mẫu đặt chỗ.
- Không dựa vào đầu vào để áp dụng quyền cho các quy tắc.
- Luôn lưu trữ mã thông báo làm mới SMTP Oauth đã cập nhật.
- Nâng cấp tinymce.

----
- Phiên bản Feb.2024: 10.0.14:

wget https://raw.githubusercontent.com/PhDLeToanThang/itil-helpdesk/master/Advanced/deploy_itsm_v10014.sh && sudo bash deploy_itsm_v10014.sh
