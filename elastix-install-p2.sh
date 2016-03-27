#!/bin/sh
echo "Now it is time to setup your Databases & Admin passwords"
read -p "Press Enter to Continue, or CTRL-C to abort."
setenforce 0
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
systemctl enable elastix-firstboot
/etc/rc.d/init.d/elastix-firstboot start
echo "Now we are running some cleanup, and making sure everything is up to date"
rm -rf /etc/yum.repos.d/elastix-cd.repo /mnt/iso/ Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso
mv /etc/yum.repos.d/elastix.repo.rpmnew /etc/yum.repos.d/elastix.repo
yum clean all
yum -y update
echo " "
echo " "
echo " "
echo " "
echo "Note: The NetworkManager was not installed, as it breaks the Virtual Network"
echo "interfaces that OpenVZ uses to provide Internet / Network access. " 
echo " "
echo " "
echo ""
echo "Now we need another reeboot to finish the setup."
read -p "Press Enter to Reboot, or CTRL-C to abort."
reboot
