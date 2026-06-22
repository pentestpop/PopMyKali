#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo!"
   exit 1
fi

TARGET_USER=${SUDO_USER:-$(logname)}
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

printf '\n============================================================\n'
printf '[+] Adding new repos\n'
printf '============================================================\n\n'

# Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /etc/apt/keyrings/sublimehq-archive.gpg
echo "deb [signed-by=/etc/apt/keyrings/sublimehq-archive.gpg] https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list

apt update

printf '\n============================================================\n'
printf '[+] Installing new apt tools\n'
printf '============================================================\n\n'

apt install -y gobuster krb5-user onesixtyone remmina rlwrap smbmap sqlmap sublime-text

printf '\n============================================================\n'
printf '[+] Cloning new GitHub repos\n'
printf '============================================================\n\n'

cd /opt

git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git
git clone https://github.com/Flangvik/SharpCollection.git
git clone https://github.com/61106960/adPEAS.git
git clone https://github.com/brightio/penelope.git
git clone https://github.com/antonioCoco/ConPtyShell.git
git clone https://github.com/diego-treitos/linux-smart-enumeration.git
git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git
git clone https://github.com/pentestpop/autoNTDS.git
git clone https://github.com/pentestpop/ARMincursore.git
git clone https://github.com/cddmp/enum4linux-ng.git
git clone https://github.com/ivan-sincek/php-reverse-shell.git
git clone https://github.com/arthaud/git-dumper.git
git clone https://github.com/nicocha30/ligolo-ng.git

printf '\n============================================================\n'
printf '[+] Building Kerbrute\n'
printf '============================================================\n\n'

git clone https://github.com/ropnop/kerbrute.git

echo "For kerbrute, please choose the ARCHS option:"
echo "1) ARCHS=arm64"
echo "2) ARCHS=amd64"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    replacement="ARCHS=arm64"
elif [ "$choice" == "2" ]; then
    replacement="ARCHS=amd64 386"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

sed -i "2s/.*/$replacement/" /opt/kerbrute/Makefile
cd /opt/kerbrute && make linux

printf '\n============================================================\n'
printf '[+] Installing pipx tools\n'
printf '============================================================\n\n'

pipx install git+https://github.com/blacklanternsecurity/NetExec
pipx install bbot

printf '\n============================================================\n'
printf '[+] Installing impacket via uv\n'
printf '============================================================\n\n'

curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$TARGET_HOME/.local/bin:$PATH"
uv tool install git+https://github.com/blacklanternsecurity/impacket

printf '\n============================================================\n'
printf '[+] Installing httpx via go\n'
printf '============================================================\n\n'

go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

printf '\n============================================================\n'
printf '[+] Setting up BloodHound CE via Docker\n'
printf '============================================================\n\n'

usermod -aG docker "$TARGET_USER"
systemctl enable --now docker
mkdir -p /opt/bloodhoundce && cd /opt/bloodhoundce
wget -q -O docker-compose.yml https://ghst.ly/getbhce

printf '\n============================================================\n'
printf '[+] Unzipping RockYou\n'
printf '============================================================\n\n'

gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null

updatedb

cat << EOF
## FINAL INSTRUCTIONS ##
1. Create a kerbrute symlink: sudo cp /opt/kerbrute/dist/kerbrute_linux_* /usr/local/bin/kerbrute
2. Add to your .zshrc if necessary:

export GOPATH=\$HOME/go
export PATH=\$PATH:/usr/lib/go/bin:\$GOPATH/bin
alias bh-start='cd /opt/bloodhoundce && docker-compose up -d'
alias bh-stop='cd /opt/bloodhoundce && docker-compose stop'
alias bh-ps='cd /opt/bloodhoundce && docker-compose ps'

EOF
