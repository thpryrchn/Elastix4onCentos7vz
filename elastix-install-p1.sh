#!/bin/sh

#Shut off SElinux & Disable firewall if running.
setenforce 0
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
chkconfig chronyd off
service chronyd stop
systemctl disable firewalld.service
systemctl stop firewalld.service

#Download Elastix and get it ready to install
if [[ $(which wget) = "" ]]; then
	yum install -y wget
fi
wget http://downloads.sourceforge.net/project/elastix/Elastix%20PBX%20Appliance%20Software/4.0.0/Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso
yum install -y epel-release
yum install p7zip p7zip-plugins -y
mkdir -p /mnt/iso
7z x -o/mnt/iso/ Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso


#Add CD as local Repository so we can install
echo "
[elastix-cd]
name=Elastix RPM Repo CD
baseurl=file:///mnt/iso/
gpgcheck=0
enabled=1
" > /etc/yum.repos.d/elastix-cd.repo

#Add Online, so it is up to date from the start
echo '[commercial-addons]
name=Commercial-Addons RPM Repository for Elastix
mirrorlist=http://mirror.elastix.org/?release=4&arch=$basearch&repo=commercial_addons
#baseurl=http://repo.elastix.org/elastix/4/commercial_addons/$basearch/
gpgcheck=1
enabled=1
gpgkey=http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix

[LowayResearch]
name=Loway Research Yum Repository
baseurl=http://yum.loway.ch/RPMS
gpgcheck=0
enabled=1

[iperfex]
name=IPERFEX RPMs repository
baseurl=http://packages.iperfex.com/centos/$releasever/$basearch/
gpgkey=http://packages.iperfex.com/RPM-GPG-KEY-iperfex-repository
enabled=1
gpgcheck=1
' > /etc/yum.repos.d/commercial-addons.repo 

echo '[elastix-base]
name=Base RPM Repository for Elastix 
mirrorlist=http://mirror.elastix.org/?release=4&arch=$basearch&repo=base
#baseurl=http://repo.elastix.org/elastix/4/base/$basearch/
gpgcheck=1
enabled=1
gpgkey=http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix

[elastix-updates]
name=Updates RPM Repository for Elastix 
mirrorlist=http://mirror.elastix.org/?release=4&arch=$basearch&repo=updates
#baseurl=http://repo.elastix.org/elastix/4/updates/$basearch/
gpgcheck=1
enabled=1
gpgkey=http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix

[elastix-beta]
name=Beta RPM Repository for Elastix 
mirrorlist=http://mirror.elastix.org/?release=4&arch=$basearch&repo=beta
#baseurl=http://repo.elastix.org/elastix/4/beta/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix

[elastix-extras]
name=Extras RPM Repository for Elastix 
mirrorlist=http://mirror.elastix.org/?release=4&arch=$basearch&repo=extras
#baseurl=http://repo.elastix.org/elastix/4/extras/$basearch/
gpgcheck=1
enabled=1
gpgkey=http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix
' > /etc/yum.repos.d/elastix.repo 

#Now we do the installation
echo "About to install Elaxtix 4.0.74-Stable-x86_64. You have 5 seconds to press CTRL-C to abort."
sleep 5

yum clean all
yum -y --nogpg install $(cat ~/instnl.txt)

#Shut off SElinux & Firewall if it got installed and turned back on
chkconfig chronyd off
service chronyd stop
systemctl disable firewalld.service
systemctl stop firewalld.service
setenforce 0
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
#rm -rf /etc/yum.repos.d/elastix-cd.repo /mnt/iso/ Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso /etc/yum.repos.d/elastix.repo 
#mv /etc/yum.repos.d/elastix.repo.rpmnew /etc/yum.repos.d/elastix.repo 
#yum clean all

#/etc/rc.d/init.d/elastix-firstboot start
clear
echo "Time to reboot!"
echo " "
echo "Run elastix-install-p2.sh after the reboot."
echo " "
read -p "Press Enter to Reboot, or CTRL-C to abort."
reboot
