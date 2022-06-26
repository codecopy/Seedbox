#!/bin/bash

tput sgr0; clear

## Load text color settings
source <(wget -qO- https://raw.githubusercontent.com/codecopy/Seedbox/main/Seedbox/tput.sh)


username=$1
password=$2
cache=$3

Cache1=$(expr $cache \* 65536)
Cache2=$(expr $cache \* 1024)

## Creating User
warn_2
pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
useradd -m -p "$pass" "$username"
normal_2


## Install Seedbox Environment
tput sgr0; clear
normal_1; echo "Start Installing Seedbox Environment"; warn_2
source <(wget -qO- https://raw.githubusercontent.com/codecopy/Seedbox/main/Seedbox/seedbox_installation.sh)
Update
qBittorrent



## Tweaking
tput sgr0; clear
normal_1; echo "Start Doing System Tweak"; warn_2
source <(wget -qO- https://raw.githubusercontent.com/codecopy/Seedbox/main/Seedbox/tweaking.sh)
CPU_Tweaking
NIC_Tweaking
Network_Other_Tweaking
Scheduler_Tweaking
file_open_limit_Tweaking
kernel_Tweaking
Tweaked_BBR

# Configue Boot Script
tput sgr0; clear
normal_1; echo "Start Configuing Boot Script"
source <(wget -qO- https://raw.githubusercontent.com/codecopy/Seedbox/main/Seedbox/boot-script.sh)
boot_script
tput sgr0; clear

# normal_1; echo "Seedbox Installation Complete"
# publicip=$(curl https://ipinfo.io/ip)
# [[ ! -z "$qbport" ]] && echo "qBittorrent $version is successfully installed, visit at $publicip:$qbport"
# [[ ! -z "$deport" ]] && echo "Deluge $Deluge_Ver is successfully installed, visit at $publicip:$dewebport"
# [[ ! -z "$bbrx" ]] && echo "Tweaked BBR is successfully installed, please reboot for it to take effect"


cat << EOF > /root/seedbox_is_successfully_installed
Seedbox is successfully installed
EOF


reboot
