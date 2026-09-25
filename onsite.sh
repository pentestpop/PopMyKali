#!/bin/bash
set -e

TOOLS_DIR="$HOME/pentest-tools"
mkdir -p "$TOOLS_DIR"

echo "=== System packages ==="
sudo apt update
sudo apt install -y nmap git python3 python3-venv python3-dev build-essential curl wget unzip pipx

echo "=== Metasploit ==="
if ! command -v msfconsole &>/dev/null; then
    echo "[!] metasploit-framework not found — not in stock Debian repos."
    echo "[!] Quick install: curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall && chmod +x /tmp/msfinstall && sudo /tmp/msfinstall"
    echo ""
    read -p "    Install metasploit now? [y/N] " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
        chmod +x /tmp/msfinstall
        sudo /tmp/msfinstall
    fi
fi

echo "=== pipx ==="
pipx ensurepath || true
export PATH="$HOME/.local/bin:$PATH"

echo "=== git-dumper ==="
pipx install --force git-dumper

echo "=== pre2k ==="
pipx install --force git+https://github.com/garrettfoster13/pre2k

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
        sudo mv /tmp/nuclei_bin/nuclei /usr/local/bin/
        rm -rf /tmp/nuclei.zip /tmp/nuclei_bin
    fi
fi
nuclei -update-templates || true

echo "=== CVE-2023-20198 ==="
if [ ! -d "$TOOLS_DIR/CVE-2023-20198" ]; then
    git clone https://github.com/smokeintheshell/CVE-2023-20198.git "$TOOLS_DIR/CVE-2023-20198"
fi
python3 -m venv "$TOOLS_DIR/CVE-2023-20198/.venv"
"$TOOLS_DIR/CVE-2023-20198/.venv/bin/pip" install requests 2>/dev/null || true

echo "=== ItWasAllADream ==="
if [ ! -d "$TOOLS_DIR/ItWasAllADream" ]; then
    git clone https://github.com/byt3bl33d3r/ItWasAllADream.git "$TOOLS_DIR/ItWasAllADream"
fi
python3 -m venv "$TOOLS_DIR/ItWasAllADream/.venv"
"$TOOLS_DIR/ItWasAllADream/.venv/bin/pip" install impacket
if ! "$TOOLS_DIR/ItWasAllADream/.venv/bin/pip" install "$TOOLS_DIR/ItWasAllADream/" 2>/dev/null; then
    echo "[!] Project install failed (poetry build backend). Deps installed, run manually:"
    echo "    cd $TOOLS_DIR/ItWasAllADream && .venv/bin/python -m itwasalladream ..."
fi

echo "=== Responder ==="
if [ ! -d "$TOOLS_DIR/Responder" ]; then
    git clone https://github.com/lgandx/Responder.git "$TOOLS_DIR/Responder"
fi
python3 -m venv "$TOOLS_DIR/Responder/.venv"
if [ -f "$TOOLS_DIR/Responder/requirements.txt" ]; then
    "$TOOLS_DIR/Responder/.venv/bin/pip" install -r "$TOOLS_DIR/Responder/requirements.txt" || true
fi

echo ""
echo "========================================="
echo "=== Verify ==="
echo "========================================="
echo -n "nmap:           "; command -v nmap &>/dev/null && nmap --version 2>/dev/null | head -1 || echo "MISSING"
echo -n "msfconsole:     "; command -v msfconsole &>/dev/null && echo "OK" || echo "MISSING — install manually (see above)"
echo -n "nuclei:         "; command -v nuclei &>/dev/null && nuclei --version 2>&1 | head -1 || echo "MISSING"
echo -n "git-dumper:     "; command -v git-dumper &>/dev/null && echo "OK" || echo "MISSING"
echo -n "pre2k:          "; command -v pre2k &>/dev/null && echo "OK" || echo "MISSING"
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
alias Responder='sudo ~/pentest-tools/Responder/.venv/bin/python ~/pentest-tools/Responder/Responder.py'
alias itwasalladream='~/pentest-tools/ItWasAllADream/.venv/bin/itwasalladream'
alias cve-2023-20198='~/pentest-tools/CVE-2023-20198/.venv/bin/python ~/pentest-tools/CVE-2023-20198/exploit.py'
ALIASES
