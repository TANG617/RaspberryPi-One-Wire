# RaspberryPi-One-Wire
# 零成本，一根线，iPad作为树莓派的屏幕
Use a single USB-C cable to transfer data between RaspberryPi 4B and iPad
仅仅使用一根USB-C to C的数据线来连接树莓派和iPad等设备，方便在外出等网络不方便的地方连接使用
可以使用和Wi-Fi连接时的全部功能，包括但不限于：80端口网站，22端口SSH等其他任何服务

#### Attention：由于个人开发，没有足够的测试设备，可能会遇到不可预知的问题，烦请在Issue提出。
方法来源：https://www.yuque.com/docs/share/37a2beac-f1db-4437-b5b8-117164af4dab?#
**功能实现演示：**

https://www.bilibili.com/video/BV1GF411v7R6/


## 优势Advantages ：

- 成本为零，适用面广：~~无论是USB3.0还是USB2.0的USB-C皆可；iPad（USB-C接口）、笔记本电、甚至安卓手机\平板，都适用~~**当前遇到了一些问题，目前仅支持Apple的带有USB-C的设备（iPad、Mac），在连接安卓、鸿蒙、Windows设备时，无法自动识别并完成配置，我们仍然在寻找解决办法，也欢迎各位在GitHub讨论。**
- 操作简单，可靠性高：每一次连接无需任何额外操作，连接即可；外出无需为手机热点无法连接而束手无策。
- 功能全面：可以实现本地局域网的全部功能，无论是SSH终端还是VNC桌面，抑或是本地网页，都可以访问。
- 「副作用」小：树莓派可以在有线连接的基础上使用Wi-Fi上网，不冲突。

## 设备需求Require :

1. 树莓派4B
2. 带有USB-C的iPad（iPad Pro 2018、2020、2021；iPad Air 4）或~~~其他带有USB-C的电脑、手机、安卓/鸿蒙平板~~~
已经测试且能够成功访问：
`iPad Air 4（USB3.0）；MacBook Pro 2021（Thunderbolt4/USB4）`
（我自己没有足够的设备完成测试，欢迎大家测试后在Issue放出结果）

## 配置方法(二者选择其一即可)：

### 1. 自动配置

```shell
git clone https://github.com/TANG617/RaspberryPi-One-Wire.git
cd RaspberryPi-One-Wire
chmod +x ./raspi_usb_c.sh
sudo ./raspi_usb_c.sh
```
### 2. 手动配置

- 在`/boot/config.txt`末尾写入`dtoverlay=dwc2`。
- 在`/boot/cmdline.txt`末尾写入`modules-load=dwc2`。
- 在`/etc/modules`末尾写入`libcomposite`。
- 在`/etc/dhcpcd.conf` 末尾写入`denyinterfaces usb0`。
- 安装dnsmasq，`sudo apt-get install dnsmasq`。
- 创建`/etc/dnsmasq.d/usb`，并写入


```shell
interface=usb0
dhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h
dhcp-option=3
leasefile-ro
```
- 创建`/etc/network/interfaces.d/usb0`，并写入

```shell
auto usb0
allow-hotplug usb0
iface usb0 inet static
  address 10.55.0.1
  netmask 255.255.255.248
```
- 创建`/root/usb.sh`，并写入

```bash
#!/bin/bash
cd /sys/kernel/config/usb_gadget/
mkdir -p pi4
cd pi4
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2
echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol
mkdir -p strings/0x409
echo "fedcba9876543211" > strings/0x409/serialnumber
echo "Ben Hardill" > strings/0x409/manufacturer
echo "PI4 USB Device" > strings/0x409/product
mkdir -p configs/c.1/strings/0x409
echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower
# Add functions here
# see gadget configurations below
# End functions
mkdir -p functions/ecm.usb0
HOST="00:dc:c8:f7:75:14" # "HostPC"
SELF="00:dd:dc:eb:6d:a1" # "BadUSB"
echo $HOST > functions/ecm.usb0/host_addr
echo $SELF > functions/ecm.usb0/dev_addr
ln -s functions/ecm.usb0 configs/c.1/
udevadm settle -t 5 || :
ls /sys/class/udc > UDC
ifup usb0
service dnsmasq restart
```
- 将`/root/usb.sh` 设置为可执行，`chmod +x /root/usb.sh`。
- 在`/etc/rc.local`文件的`exit 0`之前添加`/root/usb.sh`。
- 重新启动树莓派
