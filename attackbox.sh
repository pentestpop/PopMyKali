#!/bin/bash

if [[ $EUID -eq 0 ]]; then
   echo "Don't run as root — the script uses sudo where needed."
   exit 1
fi

TOOLS_DIR="$HOME/tools"
mkdir -p "$TOOLS_DIR"

printf '\n============================================================\n'
printf '[+] Installing apt tools\n'
printf '============================================================\n\n'

sudo apt update
sudo apt install -y exploitdb feroxbuster gobuster ligolo-ng rlwrap seclists smbmap sqlmap wordlists

printf '\n============================================================\n'
printf '[+] Cloning GitHub repos to ~/tools\n'
printf '============================================================\n\n'

for repo in \
    https://github.com/swisskyrepo/PayloadsAllTheThings.git \
    https://github.com/brightio/penelope.git \
    https://github.com/diego-treitos/linux-smart-enumeration.git \
    https://github.com/arthaud/git-dumper.git \
    https://github.com/ZephrFish/Bloodhound-CustomQueries.git \
    https://github.com/danielmiessler/SecLists.git
do
    dir="$TOOLS_DIR/$(basename "$repo" .git)"
    if [ "$repo" = "https://github.com/danielmiessler/SecLists.git" ]; then
        dir="/usr/share/seclists"
    fi
    if [ ! -d "$dir" ]; then
        if [ "$dir" = "/usr/share/seclists" ]; then
            sudo git clone "$repo" "$dir"
        else
            git clone "$repo" "$dir"
        fi
    fi
done

printf '\n============================================================\n'
printf '[+] Building Kerbrute\n'
printf '============================================================\n\n'

if [ ! -d "$TOOLS_DIR/kerbrute" ]; then
    git clone https://github.com/ropnop/kerbrute.git "$TOOLS_DIR/kerbrute"
fi
sed -i "2s/.*/ARCHS=amd64/" "$TOOLS_DIR/kerbrute/Makefile"
cd "$TOOLS_DIR/kerbrute" && make linux
sudo cp "$TOOLS_DIR/kerbrute/dist/kerbrute_linux_amd64" /usr/local/bin/kerbrute

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
mkdir -p "$TOOLS_DIR/bloodhoundce"
cd "$TOOLS_DIR/bloodhoundce"
wget -q -O docker-compose.yml https://ghst.ly/getbhce
echo "BLOODHOUND_PORT=7070" > .env
mkdir -p ~/.config/bloodhound
cp "$TOOLS_DIR/Bloodhound-CustomQueries/customqueries.json" ~/.config/bloodhound/.

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

if [ ! -d "$TOOLS_DIR/exploitdb" ]; then
    git clone https://gitlab.com/exploit-database/exploitdb.git "$TOOLS_DIR/exploitdb"
fi
sudo ln -sf "$TOOLS_DIR/exploitdb/searchsploit" /usr/local/bin/searchsploit

sudo updatedb

cat << EOF

============================================================
DONE. Add to your .zshrc if needed:
============================================================

export GOPATH=\$HOME/go
export PATH=\$PATH:/usr/lib/go/bin:\$GOPATH/bin
alias bh-start='cd ~/tools/bloodhoundce && docker compose up -d'
alias bh-stop='cd ~/tools/bloodhoundce && docker compose stop'
alias bh-ps='cd ~/tools/bloodhoundce && docker compose ps'
alias bh-restart='cd ~/tools/bloodhoundce && docker compose down && docker compose up -d'

EOF
