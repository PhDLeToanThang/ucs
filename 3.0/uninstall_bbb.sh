#!/bin/bash

# stop bbb
bbb-conf --stop

# docker cleanup
docker ps -q -all | xargs docker stop
docker ps -q -all | xargs docker rm
docker rmi --force $(docker images -a -q)
docker system prune
service docker stop
rm -rf /var/lib/docker/*
apt purge docker-ce docker-ce-cli containerd.io -y

# delete bbb dependencies
dpkg -l | grep -w bbb |  awk '{print $2}' | xargs apt-get purge -y
dpkg -l | grep -w mongodb | awk '{print $2}' | xargs apt-get purge -y
dpkg -l | grep -w kurento | awk '{print $2}' | xargs apt-get purge -y

apt-get purge openjdk* openjdk-*-jre kms-* -y
apt-get autoremove -y
apt-get clean

# delete ruby, gems
apt-get purge ruby rubygems -y
rm /var/lib/gems/2.* -rf

# delete nginx
update-rc.d nginx remove
apt purge nginx nginx-common -y

# delete redis
apt purge redis-server -y
rm -rf /var/lib/redis 
rm -rf /var/log/redis

cd /etc/apt/sources.list.d/
ls | grep bigbluebutton | xargs rm
ls | grep mongodb | xargs rm
ls | grep node | xargs rm
ls | grep rmescandon | xargs rm
ls | grep libreoffice | xargs rm

cd /etc/apt/trusted.gpg.d/
ls | grep bigbluebutton | xargs rm
ls | grep rmescandon | xargs rm
ls | grep libreoffice | xargs rm

# deactivate docker in /etc/apt/sources.list
sed -i 's/^deb \[arch\=amd64\] https\:\/\/download\.docker\.com\/linux\/ubuntu bionic stable$/\#deb \[arch\=amd64\] https\:\/\/download\.docker\.com\/linux\/ubuntu bionic stable/g' /etc/apt/sources.list

cd /var/lib/apt/lists/ && ls | grep bigbluebutton | xargs rm
cd /var/lib/apt/lists/ && ls | grep libreoffice | xargs rm
cd /var/lib/apt/lists/ && ls | grep certbot | xargs rm
cd /var/lib/apt/lists/ && ls | grep mongodb | xargs rm
cd /var/lib/apt/lists/ && ls | grep docker | xargs rm

apt-key del $(apt-key list | awk 'NR=='`expr $(apt-key list | grep --line-number --regexp "BigBlueButton" | cut --fields 1 --delimiter ":") - 1`'{print;exit}' | sed -e 's/ //g')
apt-key del $(apt-key list | awk 'NR=='`expr $(apt-key list | grep --line-number --regexp "Kurento" | cut --fields 1 --delimiter ":") - 1`'{print;exit}' | sed -e 's/ //g')
apt-key del $(apt-key list | awk 'NR=='`expr $(apt-key list | grep --line-number --regexp "MongoDB" | cut --fields 1 --delimiter ":") - 1`'{print;exit}' | sed -e 's/ //g')
apt-key del $(apt-key list | awk 'NR=='`expr $(apt-key list | grep --line-number --regexp "Docker" | cut --fields 1 --delimiter ":") - 1`'{print;exit}' | sed -e 's/ //g')

# delete leftovers like logs and other files
#rm -rf /var/bigbluebutton    #Note: if you still have recording, replay audio-video -caption -ưhiteboard - presenteration them not use delete /var/bigbluebutton folders.
rm -rf /opt/freeswitch /usr/share/etherpad-lite /usr/local/bigbluebutton /etc/bigbluebutton  
rm -rf /usr/share/meteor /usr/share/bbb-libreoffice-conversion 
rm -rf /usr/share/bbb-web 
rm -rf /etc/systemd/system/bbb-webrtc-sfu.service.d /var/tmp/bbb-kms-last-restart.txt /var/log/bigbluebutton /var/log/kurento-media-server 
rm -rf /var/log/bbb-apps-akka /var/log/bbb-fsesl-akka /var/log/bbb-webrtc-sfu /var/lib/kurento /var/kurento /var/log/mongodb /etc/kurento /run/bbb-fsesl-akka ./run/bbb-apps-akka 
rm -rf /etc/systemd/system/multi-user.target.wants/bbb-web.service 
rm -rf /etc/systemd/system/multi-user.target.wants/bbb-rap-resque-worker.service /etc/systemd/system/multi-user.target.wants/bbb-rap-starter.service ~/.bundle/cache

# delete user related content
deluser bigbluebutton 
# deluser redis
deluser mongodb
deluser kurento
# only this group needs to be removed, all other are deleted anyway!
delgroup mongodb

# update
apt-get autoremove -y
apt-get update
apt-get dist-upgrade -y