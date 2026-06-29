#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo!"
   exit 1
fi

TARGET_USER=${SUDO_USER:-$(logname)}
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

apt update

printf '\n============================================================\n'
printf '[+] Installing new apt tools\n'
printf '============================================================\n\n'

apt install -y feroxbuster gobuster rlwrap smbmap sqlmap

printf '\n============================================================\n'
printf '[+] Cloning new GitHub repos\n'
printf '============================================================\n\n'

cd /opt

git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git
git clone https://github.com/brightio/penelope.git
git clone https://github.com/diego-treitos/linux-smart-enumeration.git
git clone https://github.com/arthaud/git-dumper.git
git clone https://github.com/nicocha30/ligolo-ng.git
git clone https://github.com/ZephrFish/Bloodhound-CustomQueries.git
git clone https://github.com/danielmiessler/SecLists.git /usr/share/seclists

printf '\n============================================================\n'
printf '[+] Building Kerbrute\n'
printf '============================================================\n\n'

git clone https://github.com/ropnop/kerbrute.git
sed -i "2s/.*/ARCHS=amd64/" /opt/kerbrute/Makefile
cd /opt/kerbrute && make linux

printf '\n============================================================\n'
printf '[+] Installing BLS tools\n'
printf '============================================================\n\n'
#BBOT
pipx install git+https://github.com/blacklanternsecurity/NetExec
pipx install bbot
#Impacket
curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh
uv tool install git+https://github.com/blacklanternsecurity/impacket --python $(which python3)

printf '\n============================================================\n'
printf '[+] Installing Penelope\n'
printf '============================================================\n\n'
pipx install git+https://github.com/brightio/penelope

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
mkdir ~/.config/bloodhound  
cp /opt/Bloodhound-CustomQueries/customqueries.json ~/.config/bloodhound/.


printf '\n============================================================\n'
printf '[+] Unzipping RockYou\n'
printf '============================================================\n\n'

gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null

printf '\n============================================================\n'
printf '[+] Metasploting and Searchsploiting\n'
printf '============================================================\n\n'
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
chmod 755 /tmp/msfinstall
./tmp/msfinstall
rm /tmp/msfinstall
git clone https://gitlab.com/exploit-database/exploitdb.git /opt/exploitdb
sudo ln -s /opt/exploitdb/searchsploit /usr/local/bin/searchsploit

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
