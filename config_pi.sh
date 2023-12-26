#!/bin/bash

# get the username for this pi user, assumes just one account on pi in /home
user=$(ls /home)
echo -e "Using your pi username: $user\n"

# Set up the .bashrc with the alias
#: <<'COMMENT'
echo "alias python='python3'" >> /home/$user/.bashrc
echo "alias pip='pip3'"       >> /home/$user/.bashrc

# Set up .bash_profile in case they ssh into the pi
cat >> /home/$user/.bash_profile <<-EOMESSAGE
if [ -f ~/.bashrc ]; then
     source \$HOME/.bashrc
fi
EOMESSAGE

chown $user /home/$user/.bash_profile

echo "Setting up PI to ping server on boot."

echo "Enter the username you wish to use. a-zA-Z, no punctuation or spaces allowed: "
read username
echo $username
echo "Please enter the password for the server specified by the professor: "
read password

echo "Creating the script to ping server with 30 second delay."

read -r -d '\n' fileout <<PING_CONFIG
#!/bin/bash
sleep 30
ip=\$(hostname -I | cut -d' ' -f1)
curl "http://feherhome.no-ip.biz/ipupdate.php?username=$username&password=$password&ipaddr=\$ip"
PING_CONFIG

echo "$fileout" >> /usr/local/bin/ip_pinger.sh
chmod 755 /usr/local/bin/ip_pinger.sh

# now setup the cronjob for the ip_pinger

read -r -d '\n' fileout <<PING_CONFIG
# DO NOT EDIT THIS FILE - edit the master and reinstall.
# (/tmp/crontab.OchAOl/crontab installed on Sun Nov 17 12:33:42 2019)
# (Cron version -- \$Id: crontab.c,v 2.13 1994/01/17 03:20:37 vixie Exp $)
# Edit this file to introduce tasks to be run by cron.
# 
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
# 
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
# 
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
# 
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# 
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
# 
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command
@reboot /usr/local/bin/ip_pinger.sh
PING_CONFIG

echo "$fileout" >> /var/spool/cron/crontabs/$user
chmod 660 /var/spool/cron/crontabs/$user
chown $user  /var/spool/cron/crontabs/$user
chgrp crontab /var/spool/cron/crontabs/$user

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

# tac on some additions to the wpa_supplicant file
read -r -d '\n' fileout <<WPA_SUPPLICANT

network={
 ssid="wustl-guest-2.0"
 scan_ssid=1
 key_mgmt=NONE
 priority=100
}

network={
 ssid="gardencafe-5G"
 scan_ssid=1
 psk="gardencafe117"
}

network={
 ssid="Maplewood Deli-2G"
 scan_ssid=1
 psk="Gratitude"
}

network={
 ssid="Living Room"
 scan_ssid=1
 psk="Brownbutter32"
}
WPA_SUPPLICANT

echo "$fileout" >> /etc/wpa_supplicant/wpa_supplicant.conf
