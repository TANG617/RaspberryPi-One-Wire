echo "dtoverlay=dwc2" >> /boot/config.txt
echo "modules-load=dwc2" >> /boot/cmdline.txt
echo "libcomposite" >> /etc/modules
echo "denyinterfaces usb0" >> /etc/dhcpcd.conf
sudo apt-get install dnsmasq
echo -e "interface=usb0\ndhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h\ndhcp-option=3\nleasefile-ro" >> /etc/dnsmasq.d/usb
echo -e "auto usb0\nallow-hotplug usb0\niface usb0 inet static\n  address 10.55.0.1\n  netmask 255.255.255.248">> /etc/network/interfaces.d/usb0
cp usb.sh /root/usb.sh
chmod +x /root/usb.sh
echo -e "#!/bin/bash\n/root/usb.sh\nexit 0" > /etc/rc.local 
