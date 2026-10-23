#!/bin/bash
# spearmint.sh — unified setup: base system, attackbox, onsite tools, desktop customization

if [[ $EUID -ne 0 ]]; then
    echo 'Run with sudo. (Need sudo? usermod -aG sudo <username>)'
    exit 1
fi

TARGET_USER=${SUDO_USER:-$(logname)}
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
TARGET_UID=$(id -u "$TARGET_USER")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$TARGET_HOME/tools"

as_user() { su - "$TARGET_USER" -c "export PATH=\"$TARGET_HOME/.local/bin:$TARGET_HOME/go/bin:/usr/lib/go/bin:\$PATH\" && $1"; }
gset() { su - "$TARGET_USER" -c "DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/$TARGET_UID/bus' gsettings $1"; }
banner() { printf '\n============================================================\n[+] %s\n============================================================\n\n' "$1"; }

# ── Menu ──────────────────────────────────────────────────────────────
printf '\n============================================================\n'
printf '  spearmint.sh\n'
printf '============================================================\n\n'
echo "  1) Base System    — core packages, repos, Docker, dev tools"
echo "  2) Attackbox      — pentest repos, kerbrute, BLS tools, BloodHound CE"
echo "  3) Onsite Tools   — CVE exploits, Responder, nuclei, mitm6"
echo "  4) Poptimize      — desktop themes, oh-my-zsh, terminator, PopScripts"
echo "  A) All of the above"
echo ""
read -p "Choose (e.g. '1 2 4' or 'A'): " -a choices

run_base=false; run_attack=false; run_onsite=false; run_pop=false
for c in "${choices[@]}"; do
    case "$c" in
        1) run_base=true ;;
        2) run_attack=true ;;
        3) run_onsite=true ;;
        4) run_pop=true ;;
        [Aa]) run_base=true; run_attack=true; run_onsite=true; run_pop=true ;;
    esac
done

if ! $run_base && ! $run_attack && ! $run_onsite && ! $run_pop; then
    echo "Nothing selected. Exiting."
    exit 0
fi

mkdir -p "$TOOLS_DIR"
chown "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR"

###############################################################################
# 1) Base System
###############################################################################
if $run_base; then
    banner "Base System"

    apt update
    apt full-upgrade -y
    apt install -y \
        apt-transport-https curl docker.io git gnupg2 golang-go pipx \
        python3-pip python3-venv python-is-python3 wget zsh

    getent group docker >/dev/null && usermod -aG docker "$TARGET_USER"

    # VS Code repo
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" \
        > /etc/apt/sources.list.d/vscode.list

    # Signal-Desktop repo
    curl -fsSL https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor -o /usr/share/keyrings/signal-desktop-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" \
        > /etc/apt/sources.list.d/signal-xenial.list

    # Kali repo (pinned below Debian — only used for packages Debian doesn't have)
    curl -fsSL https://archive.kali.org/archive-key.asc | gpg --dearmor -o /usr/share/keyrings/kali-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] http://http.kali.org/kali kali-last-snapshot main contrib non-free non-free-firmware" \
        > /etc/apt/sources.list.d/kali.list
    cat > /etc/apt/preferences.d/kali.pref << 'KPREF'
Package: *
Pin: release a=kali-last-snapshot
Pin-Priority: 50
KPREF

    [ -d "$TOOLS_DIR/verybasicenum" ] || git clone https://github.com/pentestpop/verybasicenum.git "$TOOLS_DIR/verybasicenum"

    apt update
    apt install -y bat code copyq flameshot fzf libreoffice nmap plocate signal-desktop terminator tree
    as_user "pipx install name-that-hash && pipx ensurepath"

    chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR"
fi

###############################################################################
# 2) Attackbox
###############################################################################
if $run_attack; then
    banner "Attackbox"

    # Ensure Kali repo is present (may have been set up by Base, or not)
    if [ ! -f /etc/apt/sources.list.d/kali.list ]; then
        curl -fsSL https://archive.kali.org/archive-key.asc | gpg --dearmor -o /usr/share/keyrings/kali-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] http://http.kali.org/kali kali-last-snapshot main contrib non-free non-free-firmware" \
            > /etc/apt/sources.list.d/kali.list
        cat > /etc/apt/preferences.d/kali.pref << 'KPREF'
Package: *
Pin: release a=kali-last-snapshot
Pin-Priority: 50
KPREF
    fi

    apt update
    apt install -y \
        build-essential curl exploitdb feroxbuster gobuster golang-go ligolo-ng pipx \
        python3-venv rlwrap seclists smbmap sqlmap wget wordlists

    # Clone repos to ~/tools
    banner "Cloning repos to ~/tools"
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

    # Build kerbrute
    banner "Building Kerbrute"
    if [ ! -d "$TOOLS_DIR/kerbrute" ]; then
        git clone https://github.com/ropnop/kerbrute.git "$TOOLS_DIR/kerbrute"
        chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR/kerbrute"
    fi
    sed -i "2s/.*/ARCHS=amd64/" "$TOOLS_DIR/kerbrute/Makefile"
    as_user "cd '$TOOLS_DIR/kerbrute' && make linux"
    cp "$TOOLS_DIR/kerbrute/dist/kerbrute_linux_amd64" /usr/local/bin/kerbrute

    # pipx tools
    banner "BLS tools (pipx)"
    as_user "pipx ensurepath"
    as_user "pipx install --force git+https://github.com/blacklanternsecurity/NetExec"
    as_user "pipx install --force bbot"
    as_user "pipx install --force git+https://github.com/brightio/penelope"

    # Upstream impacket — the default in PATH
    as_user "pipx install --force impacket"

    # BLS impacket fork — standalone venv so it won't override upstream in PATH
    banner "BLS Impacket fork (standalone)"
    if [ ! -d "$TOOLS_DIR/impacket-bls" ]; then
        git clone https://github.com/blacklanternsecurity/impacket.git "$TOOLS_DIR/impacket-bls"
    fi
    python3 -m venv "$TOOLS_DIR/impacket-bls/.venv"
    "$TOOLS_DIR/impacket-bls/.venv/bin/pip" install "$TOOLS_DIR/impacket-bls/" 2>/dev/null || true
    chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR/impacket-bls"

    # httpx
    banner "httpx (go install)"
    as_user "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"

    # BloodHound CE
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

    # RockYou
    gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true

    # Metasploit
    banner "Metasploit"
    if ! command -v msfconsole &>/dev/null; then
        curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
        chmod 755 /tmp/msfinstall
        /tmp/msfinstall
        rm -f /tmp/msfinstall
    fi

    # Searchsploit (from git for latest)
    banner "Searchsploit"
    if [ ! -d "$TOOLS_DIR/exploitdb" ]; then
        git clone https://gitlab.com/exploit-database/exploitdb.git "$TOOLS_DIR/exploitdb"
        chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR/exploitdb"
    fi
    ln -sf "$TOOLS_DIR/exploitdb/searchsploit" /usr/local/bin/searchsploit
fi

###############################################################################
# 3) Onsite Tools
###############################################################################
if $run_onsite; then
    banner "Onsite Tools"

    apt update
    apt install -y \
        nmap git python3 python3-venv python3-dev build-essential curl wget unzip pipx

    # Metasploit (prompt if not already present)
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

    # pipx tools
    as_user "pipx ensurepath"
    as_user "pipx install --force git-dumper"
    as_user "pipx install --force git+https://github.com/garrettfoster13/pre2k"
    as_user "pipx install --force mitm6"
    as_user "pipx install --force impacket"

    # nuclei
    banner "nuclei"
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
            echo "[!] Could not resolve nuclei download URL — install manually"
        else
            curl -sL "$NUCLEI_URL" -o /tmp/nuclei.zip
            unzip -o /tmp/nuclei.zip -d /tmp/nuclei_bin
            mv /tmp/nuclei_bin/nuclei /usr/local/bin/
            rm -rf /tmp/nuclei.zip /tmp/nuclei_bin
        fi
    fi
    as_user "nuclei -update-templates" || true

    # CVE / engagement tool repos + venvs
    banner "Engagement tools (venv-based)"

    [ -d "$TOOLS_DIR/CVE-2023-20198" ] || git clone https://github.com/smokeintheshell/CVE-2023-20198.git "$TOOLS_DIR/CVE-2023-20198"
    python3 -m venv "$TOOLS_DIR/CVE-2023-20198/.venv"
    "$TOOLS_DIR/CVE-2023-20198/.venv/bin/pip" install requests 2>/dev/null || true

    [ -d "$TOOLS_DIR/ItWasAllADream" ] || git clone https://github.com/byt3bl33d3r/ItWasAllADream.git "$TOOLS_DIR/ItWasAllADream"
    python3 -m venv "$TOOLS_DIR/ItWasAllADream/.venv"
    "$TOOLS_DIR/ItWasAllADream/.venv/bin/pip" install impacket
    if ! "$TOOLS_DIR/ItWasAllADream/.venv/bin/pip" install "$TOOLS_DIR/ItWasAllADream/" 2>/dev/null; then
        echo "[!] ItWasAllADream project install failed (poetry backend). Deps installed; run manually."
    fi

    [ -d "$TOOLS_DIR/detect_bluekeep" ] || git clone https://github.com/blacklanternsecurity/detect_bluekeep.py.git "$TOOLS_DIR/detect_bluekeep"
    python3 -m venv "$TOOLS_DIR/detect_bluekeep/.venv"
    "$TOOLS_DIR/detect_bluekeep/.venv/bin/pip" install impacket 2>/dev/null || true

    [ -d "$TOOLS_DIR/CVE-2020-1472" ] || git clone https://github.com/bvcyber/CVE-2020-1472.git "$TOOLS_DIR/CVE-2020-1472"
    python3 -m venv "$TOOLS_DIR/CVE-2020-1472/.venv"
    "$TOOLS_DIR/CVE-2020-1472/.venv/bin/pip" install impacket 2>/dev/null || true

    [ -d "$TOOLS_DIR/noPac" ] || git clone https://github.com/Ridter/noPac.git "$TOOLS_DIR/noPac"
    python3 -m venv "$TOOLS_DIR/noPac/.venv"
    "$TOOLS_DIR/noPac/.venv/bin/pip" install -r "$TOOLS_DIR/noPac/requirements.txt" || true

    [ -d "$TOOLS_DIR/Responder" ] || git clone https://github.com/lgandx/Responder.git "$TOOLS_DIR/Responder"
    python3 -m venv "$TOOLS_DIR/Responder/.venv"
    if [ -f "$TOOLS_DIR/Responder/requirements.txt" ]; then
        "$TOOLS_DIR/Responder/.venv/bin/pip" install -r "$TOOLS_DIR/Responder/requirements.txt" || true
    fi

    chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR"
fi

###############################################################################
# 4) Poptimize — desktop customization
###############################################################################
if $run_pop; then
    banner "Poptimize — desktop customization"

    # PopScripts
    [ -d "$TOOLS_DIR/PopScripts" ] || git clone https://github.com/pentestpop/PopScripts.git "$TOOLS_DIR/PopScripts"
    chown -R "$TARGET_USER:$TARGET_USER" "$TOOLS_DIR/PopScripts"
    chmod +x "$TOOLS_DIR/PopScripts/link.sh" && bash "$TOOLS_DIR/PopScripts/link.sh"

    # Images
    if [ -d "$SCRIPT_DIR/images" ]; then
        cp -r "$SCRIPT_DIR/images/." "$TARGET_HOME/Pictures/"
        chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/Pictures/"
    fi

    # vbnmap symlink
    if [ -d "$TOOLS_DIR/verybasicenum" ]; then
        chmod +x "$TOOLS_DIR/verybasicenum/vbnmap.sh"
        ln -sf "$TOOLS_DIR/verybasicenum/vbnmap.sh" /usr/local/bin/vbnmap
    fi

    # Terminator
    apt install -y python3-requests terminator
    mkdir -p "$TARGET_HOME/.config/terminator/plugins"
    rm -rf /tmp/terminator-themes
    git clone --depth=1 https://github.com/EliverLara/terminator-themes.git /tmp/terminator-themes
    cp /tmp/terminator-themes/plugin/terminator-themes.py "$TARGET_HOME/.config/terminator/plugins/terminator-themes.py"
    rm -rf /tmp/terminator-themes
    if [ -f "$SCRIPT_DIR/dotfiles/themeproject/terminatorconfig" ]; then
        cp "$SCRIPT_DIR/dotfiles/themeproject/terminatorconfig" "$TARGET_HOME/.config/terminator/config"
    fi
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/terminator"

    # oh-my-zsh
    command -v zsh >/dev/null 2>&1 || apt install -y zsh
    command -v git >/dev/null 2>&1 || apt install -y git
    su - "$TARGET_USER" -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc'

    if [[ ! -f "$TARGET_HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
        echo "[!] oh-my-zsh install failed; skipping zsh plugins and .zshrc." >&2
    else
        su - "$TARGET_USER" -c "git clone https://github.com/zsh-users/zsh-autosuggestions $TARGET_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        su - "$TARGET_USER" -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting $TARGET_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        usermod --shell "$(which zsh)" "$TARGET_USER"
        if [ -f "$SCRIPT_DIR/dotfiles/.zshrc" ]; then
            cp "$SCRIPT_DIR/dotfiles/.zshrc" "$TARGET_HOME/.zshrc"
            chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.zshrc"
        fi
    fi

    # Cinnamon theme (qob)
    mkdir -p "$TARGET_HOME/.themes"
    rm -rf /tmp/cinnamon-spices-themes
    cd /tmp && git clone --depth=1 https://github.com/linuxmint/cinnamon-spices-themes.git
    cp -r /tmp/cinnamon-spices-themes/qob/files/qob "$TARGET_HOME/.themes/"
    rm -rf /tmp/cinnamon-spices-themes
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.themes"
    gset "set org.cinnamon.theme name 'qob'"

    # Kora icons
    mkdir -p "$TARGET_HOME/.icons"
    rm -rf /tmp/kora
    cd /tmp && git clone --depth=1 https://github.com/bikass/kora.git
    cp -r /tmp/kora/kora "$TARGET_HOME/.icons/"
    rm -rf /tmp/kora
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.icons"
    gset "set org.cinnamon.desktop.interface icon-theme 'kora'"

    # Posy cursor
    rm -rf /tmp/posy-improved-cursor-linux
    cd /tmp && git clone --depth=1 https://github.com/simtrami/posy-improved-cursor-linux.git
    cp -r /tmp/posy-improved-cursor-linux/Posy_Cursor "$TARGET_HOME/.icons/"
    rm -rf /tmp/posy-improved-cursor-linux
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.icons"
    gset "set org.gnome.desktop.interface cursor-theme 'Posy_Cursor'"

    # CopyQ autostart
    mkdir -p "$TARGET_HOME/.config/autostart"
    cat > "$TARGET_HOME/.config/autostart/copyq.desktop" << 'COPYQ'
[Desktop Entry]
Type=Application
Name=CopyQ
Exec=copyq
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
COPYQ
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/autostart"

    # Touchpad + shortcuts (Cinnamon)
    gset "set org.cinnamon.desktop.peripherals.touchpad tap-to-click false"
    gset "set org.cinnamon.desktop.peripherals.touchpad click-method 'fingers'"
    gset "set org.gnome.desktop.interface gtk-enable-primary-paste false"
    gset "set org.cinnamon.desktop.keybindings custom-list \"['custom0', 'custom1']\""
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ name 'Flameshot'"
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ command 'flameshot gui'"
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ binding \"['<Shift><Alt>dollar']\""
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom1/ name 'CopyQ'"
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom1/ command 'copyq show'"
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom1/ binding \"['<Ctrl><Alt>h']\""
fi

###############################################################################
# Finish
###############################################################################
updatedb 2>/dev/null || true

if $run_onsite; then
    banner "Verification (onsite tools)"
    echo -n "nmap:           "; command -v nmap &>/dev/null && nmap --version 2>/dev/null | head -1 || echo "MISSING"
    echo -n "msfconsole:     "; command -v msfconsole &>/dev/null && echo "OK" || echo "MISSING"
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
fi

octopascii="
                                                    %%@@@@@@%
                                                 @@@@@@@@@@@@@@@-
                                             -+%@@@@@@@@@@@@@@@@@@+-
                            %@@@@@         %@@@@@@@@@@@@@@@@@@@@@@@@@%         @@@@@%
                          @@@      @@      @%:@@@               @@@:@%      +@      @@@=
                         @@%         .     =@@@@                 @@@@=      .        :@@
                         @@@                . #@                 @% .                %@@=
                         @@@@               . @*                 #@ .               @@@@
                          @@@@               @@@                 @@@               @@@@
                 @@@@@@@@@@@@@@               @%                @@@               @@@@@@@@@@@@@@
              @@@@@@@@@@@@@@@@@@@             @@.       .@@@@   %@ %            @@@@@@@@@@@@@@@@@@@.
            @@@@@@@    *@@@@@@@@@@@=           @@@.           @@@:           .@@@@@@@@@@@*    #@@@@@@
           @@@@-           @@@@@@@@@@@          :@@@@@@@@@@@@@@@           .@@@@@@@@@@            @@@@.
          @@@@             @@@@@@@@@@@@@         @@@@@@@@@@@@@@@         :@@@@@@@@@@@@             @@@@
          @@@.             @@@@@ +@@@@@@@@:    @@@@@@@@@@@@@@@@@@@    .@@@@@@@@@ @@@@@              @@@
          @@@=             @@@@@@  %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@              @@@
           @@@              @@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@              @@@
            @@=              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              .@@
             @@         #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@=
             %@      =@@@@@@@@@@@@@@@@@@@@@@= @@@@@@@@@@@@@@@@@@@@@ :@@@@@@@@@@@@@@@@@@@@@@%      @@
              @     @@@@@*   -@@@@@@@@@.    @@@@@@@@@@@@@@@@@@@@@@@@@.    @@@@@@@@@=   -@@@@@     @
             *@    @@@@          @@@@@@@@@@@@@@@@@-@@@@@@@@@@@.@@@@@@@@@@@@@@@@@          @@@@    @@
            %@    @@@@             -@@@@@@@@@@@@:  @@@@@@@@@@@*  @@@@@@@@@@@@#             +@@@    :@
                  @@@                  :@@@@:     @@@@@@%@@@@@@     :%@@@*                  @@@
                  @@@.                          :@@@@@@@ %@@@@@@%                           @@@
                   @@@                        -@@@@@@@%   .@@@@@@@%                        @@@
                    @@@                    =@@@@@@@@@       @@@@@@@@@%                    @@@
                     @@@                @@@@@@@@@@@           @@@@@@@@@@@                @@@
                       @@           +@@@@@@@@@@@                 *@@@@@@@@@@@           @@:
                        @@        @@@@@@@@@@                         *@@@@@@@@@:       @@
                         @#     @@@@@@@@                                 *@@@@@@@.    .@
                         @#   .@@@@@:                                       .@@@@@+   .@
                         @    @@@@@                                           .@@@@    @
                        @    :@@@@                                             +@@@%    @
                             :@@@.                                              @@@@
                              @@@@                                             *@@@
                              +@@@.              @.            @               @@@@
                               -@@@@           @@               :@-          %@@@@
                                 @@@@@@.   @@@%                   -@@@    @@@@@@
                                    *@@@@@@-                          @@@@@@@
    "
while IFS= read -r line; do
    echo "$line"
    sleep 0.05
done <<< "$octopascii"

echo ""
echo "============================================================"
echo "  Tools installed to: $TOOLS_DIR"
echo "============================================================"
echo ""
echo "Add to your .zshrc if needed:"
echo ""
echo "  export GOPATH=\$HOME/go"
echo "  export PATH=\$PATH:/usr/lib/go/bin:\$GOPATH/bin"

if $run_attack; then
    cat << 'BHALIAS'

  # BloodHound CE
  alias bh-start='cd ~/tools/bloodhoundce && docker compose up -d'
  alias bh-stop='cd ~/tools/bloodhoundce && docker compose stop'
  alias bh-ps='cd ~/tools/bloodhoundce && docker compose ps'
  alias bh-restart='cd ~/tools/bloodhoundce && docker compose down && docker compose up -d'

  # BLS impacket fork (upstream impacket is the default in PATH)
  # Creates bls-secretsdump, bls-ntlmrelayx, bls-psexec, etc.
  for t in ~/tools/impacket-bls/.venv/bin/*.py; do alias "bls-$(basename "$t" .py)"="$t"; done
BHALIAS
fi

if $run_onsite; then
    cat << 'ONALIAS'

  # Onsite tools
  alias Responder='sudo ~/tools/Responder/.venv/bin/python ~/tools/Responder/Responder.py'
  alias itwasalladream='~/tools/ItWasAllADream/.venv/bin/itwasalladream'
  alias noPac='~/tools/noPac/.venv/bin/python ~/tools/noPac/noPac.py'
  alias bluekeep='~/tools/detect_bluekeep/.venv/bin/python ~/tools/detect_bluekeep/detect_bluekeep.py'
  alias zerologon='~/tools/CVE-2020-1472/.venv/bin/python ~/tools/CVE-2020-1472/zerologon_tester.py'
  alias cve-2023-20198='~/tools/CVE-2023-20198/.venv/bin/python ~/tools/CVE-2023-20198/exploit.py'
ONALIAS

    cat << 'USAGE'

  # Usage examples:
  # ItWasAllADream:  itwasalladream -u <user> -p <pass> -d <domain> <targets>
  # mitm6 + relay:   sudo mitm6 -d <domain>  &&  ntlmrelayx.py -6 -t ldaps://<dc-ip> -wh <attacker-ip> -l loot
  # BlueKeep:        bluekeep <IP or range>
  # ZeroLogon:       zerologon <DC-NAME> <DC-IP>
  # noPac:           noPac <domain>/<user>:'<pass>' -dc-ip <dc-ip>
  # Responder:       Responder -I <interface>
  # CVE-2023-20198:  cve-2023-20198 -t <target> -c
USAGE
fi

echo ""
