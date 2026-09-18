#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo!"
   exit 1
fi
TARGET_USER=${SUDO_USER:-$(logname)}
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
TARGET_UID=$(id -u "$TARGET_USER")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run gsettings as the target user against their LIVE session bus so the
# changes actually persist. `su -` starts a fresh login shell with no D-Bus
# session, so without this gsettings warns and no-ops. This requires the
# script to be run from inside the user's active Cinnamon session; over a
# bare SSH/TTY with no running session bus these calls will still no-op.
gset() { su - "$TARGET_USER" -c "DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/$TARGET_UID/bus' gsettings $1"; }

printf '\n============================================================\n'
printf '[+] Let'\''s get it poppin\n'
printf '============================================================\n\n'

# Install Required Utilities
apt update;
apt full-upgrade -y;
apt install -y apt-transport-https curl docker.io docker-compose-plugin git gnupg2 golang-go pipx python3-pip python3-venv python-is-python3 wget zsh

# Let the user run docker without sudo (group is created by docker.io)
getent group docker >/dev/null && usermod -aG docker "$TARGET_USER"

# Adding Repo Keys
## VS Code
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
## Signal-Desktop
curl -fsSL https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor -o /usr/share/keyrings/signal-desktop-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" > /etc/apt/sources.list.d/signal-xenial.list
## Kali (last-snapshot, pinned below Debian so it's only used for packages Debian doesn't have)
curl -fsSL https://archive.kali.org/archive-key.asc | gpg --dearmor -o /usr/share/keyrings/kali-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] http://http.kali.org/kali kali-last-snapshot main contrib non-free non-free-firmware" > /etc/apt/sources.list.d/kali.list
cat > /etc/apt/preferences.d/kali.pref << 'EOF'
Package: *
Pin: release a=kali-last-snapshot
Pin-Priority: 50
EOF

#install github repositories
printf '\n============================================================\n'
printf '[+] Installing GitHub repos:\n'
printf '============================================================\n\n'
cd /opt;

[ -d /opt/verybasicenum ] || git clone https://github.com/pentestpop/verybasicenum.git /opt/verybasicenum;

#install beloved tools
printf '\n============================================================\n'
printf '[+] Installing some tools:\n'
printf '============================================================\n\n'
apt update
apt install -y bat code copyq flameshot fzf libreoffice nmap plocate signal-desktop terminator tree;
# pipx as root installs into root's ~/.local, not the user's PATH; run it as the user
su - "$TARGET_USER" -c "pipx install name-that-hash && pipx ensurepath";

# Ask the user if they want to additional customizations
printf '\n============================================================\n'
printf '[+] Poptimizing...\n'
printf '============================================================\n\n'
echo "Would you like to optimize your Kali with aliases, terminator config, and PopScripts? Y/N";
read -p "Enter your choice: " user_input;

# Convert input to lowercase and check if it's 'y' or 'yes'
if [[ "$user_input" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    echo "Running the optimization script..."
    
    # PopScripts
    [ -d /opt/PopScripts ] || git clone https://github.com/pentestpop/PopScripts.git /opt/PopScripts
    # PopScripts symbolic links
    chmod +x /opt/PopScripts/link.sh && bash /opt/PopScripts/link.sh;
 
    # copy images folder to ~/Pictures/
    cp -r $SCRIPT_DIR/images/. $TARGET_HOME/Pictures/
    chown -R "$TARGET_USER:$TARGET_USER" $TARGET_HOME/Pictures/
    
    # create a symlink for verybasicnamp/vbnmap.sh (-f so a re-run doesn't fail)
    chmod +x /opt/verybasicenum/vbnmap.sh;
    ln -sf /opt/verybasicenum/vbnmap.sh /usr/local/bin/vbnmap;
    
    # customize terminator
    apt install -y python3-requests;
    mkdir -p $TARGET_HOME/.config/terminator/plugins;
    # git.io shut down (all links stopped redirecting 2022-04-29), so the old
    # `wget https://git.io/v5Zww` is dead. Pull the plugin from the repo instead.
    rm -rf /tmp/terminator-themes
    git clone --depth=1 https://github.com/EliverLara/terminator-themes.git /tmp/terminator-themes
    # Only terminator-themes.py (the >=1.9 version); the repo also ships
    # older-version.py, which must NOT be installed alongside it.
    cp /tmp/terminator-themes/plugin/terminator-themes.py $TARGET_HOME/.config/terminator/plugins/terminator-themes.py
    rm -rf /tmp/terminator-themes
    cp $SCRIPT_DIR/dotfiles/themeproject/terminatorconfig $TARGET_HOME/.config/terminator/config;
    chown -R "$TARGET_USER:$TARGET_USER" $TARGET_HOME/.config/terminator;

    # Install oh-my-zsh:
    # Make sure zsh + git are actually present first — the installer aborts
    # without them, and that failure is what silently broke the plugins and
    # forced the .zshrc to be copied twice.
    command -v zsh >/dev/null 2>&1 || apt install -y zsh
    command -v git >/dev/null 2>&1 || apt install -y git

    # --unattended = RUNZSH=no + CHSH=no; --keep-zshrc stops the installer
    # touching .zshrc at all, so our copy below is the only one that lands.
    su - "$TARGET_USER" -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc'

    # Only proceed if the framework really installed; otherwise skip the zsh
    # customization instead of cascading into broken plugins + a dead .zshrc.
    if [[ ! -f "$TARGET_HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
        echo "[!] oh-my-zsh install failed; skipping zsh plugins and .zshrc." >&2
    else
        su - "$TARGET_USER" -c "git clone https://github.com/zsh-users/zsh-autosuggestions $TARGET_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        su - "$TARGET_USER" -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting $TARGET_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        usermod --shell "$(which zsh)" "$TARGET_USER"

        # Deploy the custom .zshrc (safe now that --keep-zshrc left it alone).
        cp $SCRIPT_DIR/dotfiles/.zshrc $TARGET_HOME/.zshrc;
        chown "$TARGET_USER:$TARGET_USER" $TARGET_HOME/.zshrc;
    fi

    # Icons and Themes
    # Download, install, and apply the  qob theme
    mkdir -p $TARGET_HOME/.themes
    rm -rf /tmp/cinnamon-spices-themes
    cd /tmp && git clone --depth=1 https://github.com/linuxmint/cinnamon-spices-themes.git
    cp -r /tmp/cinnamon-spices-themes/qob/files/qob $TARGET_HOME/.themes/
    rm -rf /tmp/cinnamon-spices-themes
    chown -R "$TARGET_USER:$TARGET_USER" $TARGET_HOME/.themes
    gset "set org.cinnamon.theme name 'qob'"
    # Downloads, install, and apply kora icons
    mkdir -p $TARGET_HOME/.icons
    rm -rf /tmp/kora
    cd /tmp && git clone --depth=1 https://github.com/bikass/kora.git
    cp -r /tmp/kora/kora $TARGET_HOME/.icons/
    rm -rf /tmp/kora
    chown -R "$TARGET_USER:$TARGET_USER" $TARGET_HOME/.icons
    gset "set org.cinnamon.desktop.interface icon-theme 'kora'"
    # Download, install, and apply Posy-Cursor
    rm -rf /tmp/posy-improved-cursor-linux
    cd /tmp && git clone --depth=1 https://github.com/simtrami/posy-improved-cursor-linux.git
    cp -r /tmp/posy-improved-cursor-linux/Posy_Cursor $TARGET_HOME/.icons/
    rm -rf /tmp/posy-improved-cursor-linux
    chown -R "$TARGET_USER:$TARGET_USER" $TARGET_HOME/.icons
    gset "set org.gnome.desktop.interface cursor-theme 'Posy_Cursor'"

    # CopyQ Autostart
    mkdir -p "$TARGET_HOME/.config/autostart"
    cat > "$TARGET_HOME/.config/autostart/copyq.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=CopyQ
Exec=copyq
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/autostart"

    ## Touchpad Settings
    gset "set org.cinnamon.desktop.peripherals.touchpad tap-to-click false" #disable tap-to-click
    gset "set org.cinnamon.desktop.peripherals.touchpad click-method 'fingers'" # use multiple finger for right and middle click"
    gset "set org.gnome.desktop.interface gtk-enable-primary-paste false" #disable "Paste the current selection when middle-click is pressed"
    ## Shortcuts
    gset "set org.cinnamon.desktop.keybindings custom-list \"['custom0', 'custom1']\""
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ name 'Flameshot'"
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ command 'flameshot gui'"
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ binding \"['<Shift><Alt>dollar']\""
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom1/ name 'CopyQ'"
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom1/ command 'copyq show'"
    gset "set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom1/ binding \"['<Ctrl><Alt>h']\""

else
    echo "Skipping poptimization."
fi

updatedb

# ASCII art
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
# Split the ASCII art into lines and iterate over them.
# `while IFS= read -r` preserves leading spaces and doesn't clobber the
# global IFS the way `IFS=$'\n'; for ...` did.
while IFS= read -r line; do
   echo "$line"
   sleep 0.5    # Adjust the sleep duration (in seconds) as needed
done <<< "$octopascii"

# Quoted values (\$PATH, \$GOPATH) are printed literally so they can be pasted
# into .zshrc and expand at shell runtime; $TARGET_HOME expands to the real home.
cat << EOF
## FINAL INSTRUCTIONS ##
1. Add this to your .zshrc file if necessary:

export GOPATH=$TARGET_HOME/go
export PATH=\$PATH:/usr/lib/go/bin:\$GOPATH/bin

EOF
