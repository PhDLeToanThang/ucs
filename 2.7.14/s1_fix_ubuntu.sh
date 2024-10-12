#!/bin/bash -e
clear
sudo apt update -y
sudo apt list --upgradable
sudo apt autoremove -y
sudo apt upgrade -y

# Cấu hình Remote Desktop Access RDP 3389 tới máy chủ vật lý hoặc máy ảo Ubuntu 20.x/22.x LTS server
# https://thangletoan.wordpress.com/2023/10/31/cau-hinh-remote-desktop-access-rdp-3389-toi-may-chu-vat-ly-hoac-may-ao-ubuntu-20-x-22-x-lts-server/
sudo apt install xrdp -y
sudo apt install xserver-xorg-core -y
sudo apt install xserver-xorg-input-all -y
sudo apt install xorgxrdp -y

#You also need to grant access to the /etc/ssl/private/ssl-cert-snakeoil.key file for xrdp user. 
#It is available to members of the ssl-cert group by default.
# add xrdp into ssl-cert group
sudo adduser xrdp ssl-cert

# start xrdp service
sudo systemctl start xrdp

# check xrdp state
systemctl is-active xrdp 

#active
sudo systemctl enable xrdp # start xrdp on system start


# (dải ipv4 cho guacamole Server tới con VM cần điều khiển) 
#sudo ufw allow from 192.168.100.0/24 to any port 3389   

#Reboot system:  (không cần thiết)
#sudo reboot

sudo apt install wget -y
sudo apt install ufw -y
sudo apt install net-tools -y
sudo apt install gparted -y
sudo apt install ifupdown -y

# After you already have Cockpit on your server, point your web browser to: https://ip-address-of-machine:9090
sudo apt install ubuntu-desktop -y

sudo apt-get install openvswitch-switch -y
sudo systemctl start openvswitch-switch
systemctl restart systemd-networkd

#Firewall configuration:   
sudo ufw allow 3389/tcp
sudo ufw allow ssh/tcp

#sudo ufw enable 
#Cài đặt gói phần mềm để sử dụng gói apt qua giao thức HTTPS
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

#Thêm kho lưu trữ Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

#Thêm kho lưu trữ Docker vào danh sách nguồn
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#Cập nhật lại danh sách gói phần mềm và cài đặt Docker:
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io -y
# Sau khi cài đặt, Docker sẽ tự động khởi động. 
# Bạn có thể thêm người dùng hiện tại vào nhóm docker để có quyền sử dụng Docker mà không cần sử dụng lệnh sudo
sudo usermod -aG docker $USER