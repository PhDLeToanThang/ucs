######################################################################################
#    What's new BBB 2.7.16 
#		here is a short list of main changes done in this version: https://github.com/bigbluebutton/bigbluebutton/releases
# This iteration of BigBlueButton 2.7.16 contains multiple improvements on the client side, a patch for breakout rooms 
# creation specifically affecting MacOS Chrome users, added support for extra locales for transcription and other improvements.
# We welcome any feedback about this release on our bigbluebutton-dev mailing list
#
# Note that BigBlueButton 2.7.16 runs on Ubuntu Focal (20.04).
# https://docs.bigbluebutton.org/new-features/
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
wget -qO- https://raw.githubusercontent.com/bigbluebutton/bbb-install/v2.7.x-release/bbb-install.sh | bash -s -- -w -v focal-270-2.7.16 -s $FQDN -e $emailssl -g
# Passing -v focal-270 to https://raw.githubusercontent.com/bigbluebutton/bbb-install/v2.7.x-release/bbb-install.sh will always install the latest released BigBlueButton 2.7 version.
# If for some reason you would like to install this specific release, pass -v focal-270-2.7.16.
# We still recommend using -v focal-270 as this repository is continually updated with each BigBlueButton 2.7 release.
fi
