#!/bin/bash
# attackbox.sh — general-purpose pentest attack box setup.
# For client-site engagement tools, see onsite.sh.

if [[ $EUID -ne 0 ]]; then
    echo 'Run with sudo. (Need sudo? usermod -aG sudo <username>)'
    exit 1
fi

TARGET_USER=${SUDO_USER:-$(logname)}
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
TOOLS_DIR="$TARGET_HOME/tools"

as_user() { su - "$TARGET_USER" -c "export PATH=\"$TARGET_HOME/.local/bin:$TARGET_HOME/go/bin:/usr/lib/go/bin:\$PATH\" && $1"; }
banner() { printf '\n============================================================\n[+] %s\n============================================================\n\n' "$1"; }

mkdir -p "$TOOLS_DIR"
chown "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR"

banner "Installing apt tools"
apt update
apt install -y \
    build-essential curl exploitdb feroxbuster gobuster golang-go ligolo-ng \
    pipx python3-venv rlwrap seclists smbmap sqlmap wget wordlists

banner "Cloning GitHub repos to ~/tools"
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
    [ -d "$dir" ] || git clone "$repo" "$dir"
done
chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR"

banner "Building Kerbrute"
if [ ! -d "$TOOLS_DIR/kerbrute" ]; then
    git clone https://github.com/ropnop/kerbrute.git "$TOOLS_DIR/kerbrute"
    chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR/kerbrute"
fi
sed -i "2s/.*/ARCHS=amd64/" "$TOOLS_DIR/kerbrute/Makefile"
as_user "cd '$TOOLS_DIR/kerbrute' && make linux"
cp "$TOOLS_DIR/kerbrute/dist/kerbrute_linux_amd64" /usr/local/bin/kerbrute

banner "BLS tools (pipx)"
as_user "pipx ensurepath"
as_user "pipx install --force git+https://github.com/blacklanternsecurity/NetExec"
as_user "pipx install --force bbot"
as_user "pipx install --force git+https://github.com/brightio/penelope"

# Upstream impacket — the default in PATH (ntlmrelayx.py, secretsdump.py, etc.)
as_user "pipx install --force impacket"

# BLS impacket fork — standalone venv so it won't override upstream in PATH.
# Access via ~/tools/impacket-bls/.venv/bin/<tool>.py or the bls-* aliases below.
banner "BLS Impacket fork (standalone)"
if [ ! -d "$TOOLS_DIR/impacket-bls" ]; then
    git clone https://github.com/blacklanternsecurity/impacket.git "$TOOLS_DIR/impacket-bls"
fi
python3 -m venv "$TOOLS_DIR/impacket-bls/.venv"
"$TOOLS_DIR/impacket-bls/.venv/bin/pip" install "$TOOLS_DIR/impacket-bls/" 2>/dev/null || true

banner "httpx (go install)"
as_user "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"

banner "BloodHound CE (Docker)"
usermod -aG docker "$TARGET_USER"
systemctl enable --now docker
mkdir -p "$TOOLS_DIR/bloodhoundce"
chown "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR/bloodhoundce"
( cd "$TOOLS_DIR/bloodhoundce" \
    && wget -q -O docker-compose.yml https://ghst.ly/getbhce \
    && echo "BLOODHOUND_PORT=7070" > .env )
chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR/bloodhoundce"
mkdir -p "$TARGET_HOME/.config/bloodhound"
cp "$TOOLS_DIR/Bloodhound-CustomQueries/customqueries.json" "$TARGET_HOME/.config/bloodhound/."
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/bloodhound"

gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true

banner "Metasploit"
if ! command -v msfconsole &>/dev/null; then
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
    chmod 755 /tmp/msfinstall
    /tmp/msfinstall
    rm -f /tmp/msfinstall
fi

banner "Searchsploit"
if [ ! -d "$TOOLS_DIR/exploitdb" ]; then
    git clone https://gitlab.com/exploit-database/exploitdb.git "$TOOLS_DIR/exploitdb"
fi
ln -sf "$TOOLS_DIR/exploitdb/searchsploit" /usr/local/bin/searchsploit

chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR"
updatedb 2>/dev/null || true

cat << 'EOF'

============================================================
DONE. Add to your .zshrc if needed:
============================================================

export GOPATH=$HOME/go
export PATH=$PATH:/usr/lib/go/bin:$GOPATH/bin

# BloodHound CE
alias bh-start='cd ~/tools/bloodhoundce && docker compose up -d'
alias bh-stop='cd ~/tools/bloodhoundce && docker compose stop'
alias bh-ps='cd ~/tools/bloodhoundce && docker compose ps'
alias bh-restart='cd ~/tools/bloodhoundce && docker compose down && docker compose up -d'

# BLS impacket fork (upstream impacket is the default in PATH)
# Creates bls-secretsdump, bls-ntlmrelayx, bls-psexec, etc.
for t in ~/tools/impacket-bls/.venv/bin/*.py; do alias "bls-$(basename "$t" .py)"="$t"; done

EOF
