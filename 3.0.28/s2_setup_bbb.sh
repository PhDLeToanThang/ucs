#!/bin/bash -e
# ============================================================
# s2_setup_bbb.sh - Cai dat BigBlueButton 3.0.28 tren Ubuntu 22.04
# ============================================================
# Tham khao:
#   https://github.com/bigbluebutton/bbb-install/blob/v3.0.x-release/bbb-install.sh
#   https://github.com/bigbluebutton/bigbluebutton/releases/tag/v3.0.28
# ============================================================
clear
cd ~

echo "=============================================="
echo "  CAI DAT BigBlueButton 3.0.28"
echo "  Ubuntu 22.04 LTS (Jammy)"
echo "=============================================="
echo ""

# Nhap thong so
echo "Nhap FQDN (VD: demo.company.vn):"
read -e FQDN

echo "Nhap Email admin cho SSL Let's Encrypt:"
read -e emailssl

echo ""
echo "Lua chon phien ban cai dat:"
echo "  1) Phien ban moi nhat (jammy-300) - khuyen nghi"
echo "  2) Phien ban 3.0.28 cu the (jammy-300-3.0.28)"
read -e version_choice

echo ""
echo "Co cai Greenlight (giao dien web)? (y/n):"
read -e install_greenlight

echo ""
echo "Co cai coturn (TURN server) tich hop? (y/n):"
read -e install_turn

echo ""
echo "=============================================="
echo "  THONG SO CAI DAT:"
echo "  FQDN: $FQDN"
echo "  Email: $emailssl"
echo "  Greenlight: $install_greenlight"
echo "  TURN: $install_turn"
echo "=============================================="
echo ""
echo "Tiep tuc cai dat? (y/n)"
read -e run

if [ "$run" == "n" ] || [ "$run" == "N" ]; then
  echo "Huy bo cai dat."
  exit
fi

# Xac dinh tham so version
if [ "$version_choice" == "2" ]; then
  BBB_VERSION="jammy-300-3.0.28"
  echo "=== Cai dat BBB 3.0.28 cu the ==="
else
  BBB_VERSION="jammy-300"
  echo "=== Cai dat BBB phien ban moi nhat (3.0.x) ==="
fi

# Xay dung command
CMD="bash <(wget -qO- https://raw.githubusercontent.com/bigbluebutton/bbb-install/v3.0.x-release/bbb-install.sh) -- -w -v $BBB_VERSION -s $FQDN -e $emailssl"

if [ "$install_greenlight" == "y" ] || [ "$install_greenlight" == "Y" ]; then
  CMD="$CMD -g"
fi

if [ "$install_turn" == "y" ] || [ "$install_turn" == "Y" ]; then
  CMD="$CMD -c $FQDN -t $emailssl"
fi

echo ""
echo "=== Dang chay: $CMD ==="
echo ""

# Thuc thi
eval $CMD

echo ""
echo "=== Kiem tra cai dat ==="
sudo bbb-conf --check
sudo bbb-conf --status

echo ""
echo "=============================================="
echo "  CAI DAT HOAN TAT!"
echo "  FQDN: https://$FQDN"
echo "  Chay 'sudo bbb-conf --secret' de lay API secret"
echo "=============================================="
