#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo!"
   exit 1
fi

TARGET_USER=${SUDO_USER:-$(logname)}
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

printf '\n============================================================\n'
printf '[+] Adding Sublime Key\n'
printf '============================================================\n\n'

# Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /etc/apt/keyrings/sublimehq-archive.gpg
echo "deb [signed-by=/etc/apt/keyrings/sublimehq-archive.gpg] https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list

printf '\n============================================================\n'
printf '[+] Installing new apt tools\n'
printf '============================================================\n\n'

apt install -y krb5-user onesixtyone remmina sublime-text

printf '\n============================================================\n'
printf '[+] Cloning new GitHub repos\n'
printf '============================================================\n\n'

cd /opt
git clone https://github.com/Flangvik/SharpCollection.git
git clone https://github.com/61106960/adPEAS.git
git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git
git clone https://github.com/pentestpop/autoNTDS.git
git clone https://github.com/pentestpop/ARMincursore.git
git clone https://github.com/cddmp/enum4linux-ng.git
git clone https://github.com/ivan-sincek/php-reverse-shell.git
git clone https://github.com/antonioCoco/ConPtyShell.git
