######################################################################################
#    What's new BBB 3.0 Dev RC3 
#		here is a short list of main changes done in this version: https://github.com/bigbluebutton/bigbluebutton/releases
# This iteration of BigBlueButton 3.0 contains multiple improvements on the client side, a patch for breakout rooms 
# creation specifically affecting MacOS Chrome users, added support for extra locales for transcription and other improvements.
# We welcome any feedback about this release on our bigbluebutton-dev mailing list
#
# Note that BigBlueButton 3.0 runs on Ubuntu Jammy (22.04).
# https://github.com/bigbluebutton/bigbluebutton/tree/v3.0.x-release/docs
#
######################################################################################
#!/bin/bash -e
clear
cd ~

############### Tham số cần thay đổi ở đây ###################
echo "FQDN: e.g: demo.company.vn"   # Đổi địa chỉ web thứ nhất Website Master for Resource code - để tạo cùng 1 Source code duy nhất 
read -e FQDN

echo "Email Address of Admin CA SSL/TLS"   # Địa chỉ email của nhà quản trị SSL/TLS cho HTTPS
read -e emailssl

echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
  exit
else

#Step 3. 
wget -qO- https://raw.githubusercontent.com/bigbluebutton/bbb-install/v3.0.x-release/bbb-install.sh | bash -s -- -w -v jammy-300 -s $FQDN -e $emailssl -g
# Passing -v jammy-300 to https://raw.githubusercontent.com/bigbluebutton/bbb-install/v3.0.x-release/bbb-install.sh will always install the latest released BigBlueButton 3.0 version.

fi
