#!/bin/bash

# get the username for this pi user, assumes just one account on pi in /home
user=$(ls /home)
echo -e "Using your pi username: $user\n"

# Set up the .bashrc with the alias & environment variables
#: <<'COMMENT'
echo "alias python='python3'" >> /home/$user/.bashrc
echo "alias pip='pip3'"       >> /home/$user/.bashrc
echo "export PIP_BREAK_SYSTEM_PACKAGES=1" >> /home/$user/.bashrc

# Set up .bash_profile in case they ssh into the pi
cat >> /home/$user/.bash_profile <<-EOMESSAGE
if [ -f ~/.bashrc ]; then
     source \$HOME/.bashrc
fi
EOMESSAGE

chown $user /home/$user/.bash_profile

# copy the nanorc file over so nano shows the line numbers and syntax

cp example_nanorc /home/$user/.nanorc
chown $user  /home/$user/.nanorc

# tac on the changes to the /boot/config.txt file
read -r -d '\n' fileout <<CONFIG_TXT

# added by the ESE 205 setup script
framebuffer_width=1280
framebuffer_height=720
hdmi_force_hotplug=1
CONFIG_TXT

echo "$fileout" >> /boot/config.txt

# put in an entry for wustl-2.0 wifi
cat >> /etc/NetworkManager/system-connections/wustl-2.0.nmconnection <<WIFITEXT
[connection]
id=wustl-2.0
uuid=8dfaed5f-5154-4087-9a7c-b259b1d0a9a5
type=wifi
interface-name=wlan0

[wifi]
mode=infrastructure
ssid=wustl-2.0

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto

[proxy]
WIFITEXT
