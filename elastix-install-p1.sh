#!/bin/sh

#Shut off SElinux & Disable firewall if running.
setenforce 0
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config

#Download Elastix and get it ready to install
if [[ $(which wget) = "" ]]; then
	yum install -y wget
fi
if [ -e Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso ]; then
	echo "ISO is already avalible. Skipping download"
else
	wget https://kent.dl.sourceforge.net/project/vaak/Elastix/4/Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso
fi
if [ -e /etc/yum.repos.d/commercial-addons.repo ]; then
	echo "Seems to have an Install attemt that failed. Clean up yum"
	rm -f /etc/yum.repos.d/elastix* /etc/yum.repos.d/commercial-addons.repo
	yum clean all
	yum -y update
fi
yum -y update
yum install -y epel-release
yum install p7zip p7zip-plugins -y
mkdir -p /mnt/iso
if [[ $(which 7z) = "" ]]; then
	echo "7x is missing. Try running again"
	exit 1
fi
7z x -o/mnt/iso/ Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso
sleep 1

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
#mirrorlist=http://mirror.elastix.org/?release=4&arch=$basearch&repo=commercial_addons
baseurl=http://repo.elastix.org/elastix/4/commercial_addons/$basearch/
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
baseurl=http://packages.iperfex.com/centos/7/$basearch/
gpgkey=http://packages.iperfex.com/RPM-GPG-KEY-iperfex-repository
enabled=1
gpgcheck=1
' > /etc/yum.repos.d/commercial-addons.repo 

echo '[elastix-base]
name=Base RPM Repository for Elastix 
#mirrorlist=http://mirror.elastix.org/?release=4&arch=$basearch&repo=base
baseurl=http://repo.elastix.org/elastix/4/base/$basearch/
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
#mirrorlist=http://mirror.elastix.org/?release=4&arch=$basearch&repo=beta
baseurl=http://repo.elastix.org/elastix/4/beta/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix

[elastix-extras]
name=Extras RPM Repository for Elastix 
#mirrorlist=http://mirror.elastix.org/?release=4&arch=$basearch&repo=extras
baseurl=http://repo.elastix.org/elastix/4/extras/$basearch/
gpgcheck=1
enabled=1
gpgkey=http://repo.elastix.org/elastix/RPM-GPG-KEY-Elastix
' > /etc/yum.repos.d/elastix.repo 

#Now we do the installation
echo "About to install Elaxtix 4.0.74-Stable-x86_64. You have 5 seconds to press CTRL-C to abort."
sleep 5

yum clean all
yum -y update 
sleep 3
yum -y --nogpg install $(cat inst1.txt)
sleep 3
yum -y install asterisk
yum -y install elastix
#Run a 2nd time in case it missed something
yum -y --nogpg install $(cat inst2.txt)
yum -clean all
yum -y update 

#Shut off SElinux and Firewall. Be sure to configure it in Elastix!
setenforce 0
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
cp -a /etc/sysconfig/iptables /etc/sysconfig/iptables.org-elastix-"$(/bin/date "+%Y-%m-%d-%H-%M-%S")"
# systemctl stop chronyd
# systemctl stop firewalld
# systemctl stop iptables
# systemctl disable chronyd
# systemctl disable firewalld
# systemctl disable iptables
# systemctl disable elastix-firstboot
#Fix for "/bin/df: '/etc/fstab': No such file or directory"
touch /etc/fstab

#/etc/rc.d/init.d/elastix-firstboot start
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "Time to reboot!"
echo " "
echo "Run elastix-install-p2.sh after the reboot."
echo " "
read -p "Press Enter to Reboot, or CTRL-C to abort."
reboot
