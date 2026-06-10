#!/bin/bash -e
# ============================================================
# uninstall_bbb.sh - Go bo hoan toan BigBlueButton 3.0.x
# ============================================================
# Can than: Script nay se xoa TOAN BO BBB va thanh phan lien quan
#   - BIGBLUEBUTTON: xoa toan bo packages, config, logs
#   - DOCKER: xoa images, containers
#   - MONGODB: xoa packages, data
#   - REDIS: xoa packages, data
#   - NGUY CO mat recordings neu xoa /var/bigbluebutton
# ============================================================
clear
echo "=== CAN BAO: XOA HOAN TOAN BigBlueButton! ==="
echo "Nhap 'yes' de xac nhan:"
read -e confirm
if [ "$confirm" != "yes" ]; then
  echo "Huy bo."
  exit
fi

echo "=== 1. Stop BBB services ==="
bbb-conf --stop 2>/dev/null || true

echo "=== 2. Cleanup Docker ==="
docker ps -q -all | xargs docker stop 2>/dev/null || true
docker ps -q -all | xargs docker rm 2>/dev/null || true
docker rmi --force $(docker images -a -q) 2>/dev/null || true
docker system prune -f 2>/dev/null || true
systemctl stop docker 2>/dev/null || true
rm -rf /var/lib/docker/* 2>/dev/null || true
apt purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin 2>/dev/null || true

echo "=== 3. Xoa BBB packages ==="
# BBB 3.0 packages
dpkg -l 2>/dev/null | grep -w bbb | awk '{print $2}' | xargs apt-get purge -y 2>/dev/null || true

# MongoDB
dpkg -l 2>/dev/null | grep -w mongodb | awk '{print $2}' | xargs apt-get purge -y 2>/dev/null || true
dpkg -l 2>/dev/null | grep -w mongosh | awk '{print $2}' | xargs apt-get purge -y 2>/dev/null || true
dpkg -l 2>/dev/null | grep -w mongod | awk '{print $2}' | xargs apt-get purge -y 2>/dev/null || true

# Kurento (BBB 2.x) - co the khong con trong 3.0
dpkg -l 2>/dev/null | grep -w kurento | awk '{print $2}' | xargs apt-get purge -y 2>/dev/null || true
dpkg -l 2>/dev/null | grep -w kms | awk '{print $2}' | xargs apt-get purge -y 2>/dev/null || true

# Java
apt-get purge -y openjdk* openjdk-*-jre 2>/dev/null || true

# Ruby & Gems
apt-get purge -y ruby rubygems 2>/dev/null || true
rm -rf /var/lib/gems/* 2>/dev/null || true

# Nginx
systemctl stop nginx 2>/dev/null || true
update-rc.d nginx remove 2>/dev/null || true
apt purge -y nginx nginx-common nginx-core 2>/dev/null || true

# Redis
systemctl stop redis-server 2>/dev/null || true
apt purge -y redis-server 2>/dev/null || true
rm -rf /var/lib/redis 2>/dev/null || true
rm -rf /var/log/redis 2>/dev/null || true

# NodeJS
apt purge -y nodejs 2>/dev/null || true

# Coturn (TURN) - neu co
apt purge -y coturn 2>/dev/null || true

echo "=== 4. Xoa apt sources & keys ==="
cd /etc/apt/sources.list.d/
ls 2>/dev/null | grep bigbluebutton | xargs rm -f 2>/dev/null || true
ls 2>/dev/null | grep mongodb | xargs rm -f 2>/dev/null || true
ls 2>/dev/null | grep node | xargs rm -f 2>/dev/null || true
ls 2>/dev/null | grep libreoffice | xargs rm -f 2>/dev/null || true
ls 2>/dev/null | grep docker | xargs rm -f 2>/dev/null || true

cd /etc/apt/trusted.gpg.d/
ls 2>/dev/null | grep bigbluebutton | xargs rm -f 2>/dev/null || true
ls 2>/dev/null | grep libreoffice | xargs rm -f 2>/dev/null || true

cd /var/lib/apt/lists/
ls 2>/dev/null | grep bigbluebutton | xargs rm -f 2>/dev/null || true
ls 2>/dev/null | grep libreoffice | xargs rm -f 2>/dev/null || true
ls 2>/dev/null | grep certbot | xargs rm -f 2>/dev/null || true
ls 2>/dev/null | grep mongodb | xargs rm -f 2>/dev/null || true
ls 2>/dev/null | grep docker | xargs rm -f 2>/dev/null || true
ls 2>/dev/null | grep node | xargs rm -f 2>/dev/null || true

# Xoa GPG keys
for keyname in "BigBlueButton" "Kurento" "MongoDB" "Docker" "LibreOffice" "NodeSource"; do
  keynum=$(apt-key list 2>/dev/null | grep --line-number --regexp="$keyname" | cut --fields 1 --delimiter ":" | head -1)
  if [ -n "$keynum" ]; then
    target=$((keynum - 1))
    keyid=$(apt-key list 2>/dev/null | awk "NR==${target}"'{print;exit}' | sed -e 's/ //g')
    if [ -n "$keyid" ]; then
      apt-key del "$keyid" 2>/dev/null || true
    fi
  fi
done

echo "=== 5. Xoa thu muc cau hinh & log ==="
# Chu y: Giu lai /var/bigbluebutton neu con recordings can giu
echo "Giun lai recordings? (y/n):"
read -e keep_recordings

rm -rf /opt/freeswitch 2>/dev/null || true
rm -rf /usr/share/etherpad-lite 2>/dev/null || true
rm -rf /usr/local/bigbluebutton 2>/dev/null || true
rm -rf /etc/bigbluebutton 2>/dev/null || true
rm -rf /usr/share/meteor 2>/dev/null || true
rm -rf /usr/share/bbb-libreoffice-conversion 2>/dev/null || true
rm -rf /usr/share/bbb-web 2>/dev/null || true
rm -rf /etc/systemd/system/bbb-webrtc-sfu.service.d 2>/dev/null || true
rm -rf /var/tmp/bbb-kms-last-restart.txt 2>/dev/null || true
rm -rf /var/log/bigbluebutton 2>/dev/null || true
rm -rf /var/log/kurento-media-server 2>/dev/null || true
rm -rf /var/log/bbb-apps-akka 2>/dev/null || true
rm -rf /var/log/bbb-fsesl-akka 2>/dev/null || true
rm -rf /var/log/bbb-webrtc-sfu 2>/dev/null || true
rm -rf /var/lib/kurento 2>/dev/null || true
rm -rf /var/kurento 2>/dev/null || true
rm -rf /var/log/mongodb 2>/dev/null || true
rm -rf /etc/kurento 2>/dev/null || true
rm -rf /run/bbb-fsesl-akka 2>/dev/null || true
rm -rf /run/bbb-apps-akka 2>/dev/null || true
rm -rf /etc/systemd/system/multi-user.target.wants/bbb-web.service 2>/dev/null || true
rm -rf /etc/systemd/system/multi-user.target.wants/bbb-rap-resque-worker.service 2>/dev/null || true
rm -rf /etc/systemd/system/multi-user.target.wants/bbb-rap-starter.service 2>/dev/null || true
rm -rf ~/.bundle/cache 2>/dev/null || true

# BBB 3.0 GraphQL (co the co)
rm -rf /etc/default/bbb-graphql-server 2>/dev/null || true
rm -rf /var/log/bbb-graphql-* 2>/dev/null || true

if [ "$keep_recordings" != "y" ] && [ "$keep_recordings" != "Y" ]; then
  rm -rf /var/bigbluebutton 2>/dev/null || true
  echo "Da xoa recordings."
else
  echo "Giu lai recordings tai /var/bigbluebutton"
fi

echo "=== 6. Xoa user & group ==="
deluser bigbluebutton 2>/dev/null || true
deluser mongodb 2>/dev/null || true
deluser kurento 2>/dev/null || true
delgroup mongodb 2>/dev/null || true

echo "=== 7. Don dep & update ==="
apt-get autoremove -y 2>/dev/null || true
apt-get clean 2>/dev/null || true

echo ""
echo "=== DA GO BO HOAN TOAN BigBlueButton! ==="
echo "Khoi dong lai may de hoan tat: sudo reboot"
