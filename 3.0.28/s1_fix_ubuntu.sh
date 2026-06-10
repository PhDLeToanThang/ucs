#!/bin/bash -e
# ============================================================
# s1_fix_ubuntu.sh - Chuẩn bị Ubuntu 22.04 LTS cho BBB 3.0.28
# ============================================================
# Sử dụng: sudo bash s1_fix_ubuntu.sh
# ============================================================
clear
echo "=== BUOC 1: Cap nhat he thong Ubuntu 22.04 LTS ==="
sudo apt update -y
sudo apt list --upgradable
sudo apt autoremove -y
sudo apt upgrade -y

echo "=== Cai dat Remote Desktop (xrdp) - port 3389 ==="
# https://thangletoan.wordpress.com/2023/10/31/cau-hinh-remote-desktop-access-rdp-3389-toi-may-chu-vat-ly-hoac-may-ao-ubuntu-20-x-22-x-lts-server/
sudo apt install xrdp -y
sudo apt install xserver-xorg-core -y
sudo apt install xserver-xorg-input-all -y
sudo apt install xorgxrdp -y

# Grant access to /etc/ssl/private/ssl-cert-snakeoil.key for xrdp user
sudo adduser xrdp ssl-cert

# Start and enable xrdp
sudo systemctl start xrdp
sudo systemctl enable xrdp
systemctl is-active xrdp

echo "=== Cai dat cac goi co ban ==="
sudo apt install wget curl -y
sudo apt install ufw -y
sudo apt install net-tools -y
sudo apt install software-properties-common -y
sudo apt install apt-transport-https ca-certificates -y

echo "=== Cai dat Docker (bat buoc cho BBB 3.0) ==="
# Xoa Docker cu neu co
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Them Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Them Docker repo
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Cai Docker
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Add user vao group docker
sudo usermod -aG docker $USER

echo "=== Cai dat Ubuntu Desktop (tu chon - comment neu khong can) ==="
# Chu y: Rat nang, chi nen dung cho dev, khong dung cho production
# sudo apt install ubuntu-desktop -y

echo "=== Cau hinh Firewall co ban ==="
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3389/tcp
sudo ufw allow 16384:32768/udp

echo "=== Kiem tra Docker ==="
sudo systemctl enable docker
sudo systemctl start docker
docker --version

echo ""
echo "=== HOAN TAT BUOC 1 ==="
echo "Vui long dang xuat va dang nhap lai de group docker co hieu luc."
echo "Sau do chay: sudo bash s2_setup_bbb.sh"
