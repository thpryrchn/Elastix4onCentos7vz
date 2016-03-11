# Elastix4onCentos7vz
Install Elastix 4 on Centos 7 OpenVZ

Ok, So I wanted to setup elastix in a cloud. There are some VPS's that are built for VOIP, but if you want it even cheaper than $30 per month, then there are other options out there. If only you could just install it on a VPS with centos 7... I use [Hostmada's OVZ-3](https://hostmada.com/openvz-vps) plan for $5.99 per month.

I searched for instructions on how to do it, and didn't find any. Found instructions on Asteriskonvps.com that helped me out. [How to install Elastix on a VPS without loop devices (OpenVZ)](http://asteriskonvps.com/elastix/how-to-install-elastix-on-a-vps-without-loop-devices-openvz/)

I expounded on their instructions, and made scripts that extract the source ISO instead of repacking it then sending it to the VPS/openVZ. Since OpenVZ does not have access to a loop device by default, this gets around it.

These scripts also work well if you have a linux server that you want to run elastix in a openVZ container also.

I wrote a couple scripts that do everything for you. It installs everything except for NetworkManager, which breaks the virtual network interfaces and makes it unreachable.

### Instalation
To start out, ssh into your host. Then at the command, download the install scripts. If you do not have wget, install it by `yum -y install wget`, then you will just need to run this:

	wget -O Elastix4onCentos7vz.tar.gz --no-check-certificate https://github.com/thpryrchn/Elastix4onCentos7vz/tarball/master
	tar zxvf Elastix4onCentos7vz.tar.gz --strip-components=1 
	./elastix-install-p1.sh

This will download the Elastix Install DVD, unpack it to /mnt/iso, add it as a source to yum, then install all the files. It also adds Elastix's repo, so that it starts with the latest version

Once it finishes, it needs to reboot. Reboot, then run the 2nd script

	./elastix-install-p2.sh
	
This will run the First-Run for Elastix that will have you setup the Mysql Database password, and your ADMIN password.

It will also clean off the install files so they won't take up space anymore.

It also adds the default Firewall that Elastix comes with, backing up the iptables file.

After it finishes, it will have you reboot once more. Then you can configure through the Web interface, and however else you work with Elastix.