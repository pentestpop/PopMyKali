#!/bin/bash

if [[ $EUID -eq 0 ]]; then
   echo "Don't run as root — the script uses sudo where needed."
   exit 1
fi

printf '\n============================================================\n'
printf '[+] Installing apt tools\n'
printf '============================================================\n\n'

sudo apt update
sudo apt install -y exploitdb feroxbuster gobuster ligolo-ng rlwrap seclists smbmap sqlmap wordlists

printf '\n============================================================\n'
printf '[+] Cloning GitHub repos to /opt\n'
printf '============================================================\n\n'

sudo mkdir -p /opt
for repo in \
    https://github.com/swisskyrepo/PayloadsAllTheThings.git \
    https://github.com/brightio/penelope.git \
    https://github.com/diego-treitos/linux-smart-enumeration.git \
    https://github.com/arthaud/git-dumper.git \
    https://github.com/ZephrFish/Bloodhound-CustomQueries.git \
    https://github.com/danielmiessler/SecLists.git
do
    dir="/opt/$(basename "$repo" .git)"
    if [ "$repo" = "https://github.com/danielmiessler/SecLists.git" ]; then
        dir="/usr/share/seclists"
    fi
    if [ ! -d "$dir" ]; then
        sudo git clone "$repo" "$dir"
        sudo chown -R "$(whoami):" "$dir"
    fi
done

printf '\n============================================================\n'
printf '[+] Building Kerbrute\n'
printf '============================================================\n\n'

if [ ! -d /opt/kerbrute ]; then
    sudo git clone https://github.com/ropnop/kerbrute.git /opt/kerbrute
    sudo chown -R "$(whoami):" /opt/kerbrute
fi
sed -i "2s/.*/ARCHS=amd64/" /opt/kerbrute/Makefile
cd /opt/kerbrute && make linux
sudo cp /opt/kerbrute/dist/kerbrute_linux_amd64 /usr/local/bin/kerbrute

printf '\n============================================================\n'
printf '[+] Installing BLS tools (pipx + uv)\n'
printf '============================================================\n\n'

pipx ensurepath || true
export PATH="$HOME/.local/bin:$PATH"

pipx install --force git+https://github.com/blacklanternsecurity/NetExec
pipx install --force bbot
pipx install --force git+https://github.com/brightio/penelope

if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi
uv tool install git+https://github.com/blacklanternsecurity/impacket --python "$(which python3)"

printf '\n============================================================\n'
printf '[+] Installing httpx via go\n'
printf '============================================================\n\n'

go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

printf '\n============================================================\n'
printf '[+] Setting up BloodHound CE via Docker\n'
printf '============================================================\n\n'

sudo usermod -aG docker "$(whoami)"
sudo systemctl enable --now docker
sudo mkdir -p /opt/bloodhoundce
sudo chown "$(whoami):" /opt/bloodhoundce
cd /opt/bloodhoundce
wget -q -O docker-compose.yml https://ghst.ly/getbhce
echo "BLOODHOUND_PORT=7070" > .env
mkdir -p ~/.config/bloodhound
cp /opt/Bloodhound-CustomQueries/customqueries.json ~/.config/bloodhound/.

printf '\n============================================================\n'
printf '[+] Unzipping RockYou\n'
printf '============================================================\n\n'

sudo gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true

printf '\n============================================================\n'
printf '[+] Metasploit\n'
printf '============================================================\n\n'

if ! command -v msfconsole &>/dev/null; then
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
    chmod 755 /tmp/msfinstall
    sudo /tmp/msfinstall
    rm /tmp/msfinstall
fi

printf '\n============================================================\n'
printf '[+] Searchsploit\n'
printf '============================================================\n\n'

if [ ! -d /opt/exploitdb ]; then
    sudo git clone https://gitlab.com/exploit-database/exploitdb.git /opt/exploitdb
fi
sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit

sudo updatedb

cat << EOF

============================================================
DONE. Add to your .zshrc if needed:
============================================================

export GOPATH=\$HOME/go
export PATH=\$PATH:/usr/lib/go/bin:\$GOPATH/bin
alias bh-start='cd /opt/bloodhoundce && docker compose up -d'
alias bh-stop='cd /opt/bloodhoundce && docker compose stop'
alias bh-ps='cd /opt/bloodhoundce && docker compose ps'
alias bh-restart='cd /opt/bloodhoundce && docker compose down && docker compose up -d'

EOF
