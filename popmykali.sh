#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo!"
   exit 1
fi

printf '\n============================================================\n'
printf '[+] Let'\''s get it poppin\n'
printf '============================================================\n\n'

# Install Required Utilities
apt update;
apt full-upgrade -y;
apt install apt-transport-https curl docker.io docker-compose git gnupg2 golang-go pip pipx python-is-python3 wget zsh

# Adding Repo Keys
## Sublime-Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /etc/apt/keyrings/sublimehq-archive.gpg;
echo "deb [signed-by=/etc/apt/keyrings/sublimehq-archive.gpg] https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list;
## VS Code
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -;
add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main";
## Signal
### 1. Install our official public software signing key:
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
cat signal-desktop-keyring.gpg | tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
### 2. Add our repository to your list of repositories:
wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
cat signal-desktop.sources | tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null

#install github repositories
printf '\n============================================================\n'
printf '[+] Installing GitHub repos:\n'
printf '============================================================\n\n'
cd /opt;

git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git;

git clone https://github.com/Flangvik/SharpCollection.git;

git clone https://github.com/61106960/adPEAS.git;

git clone https://github.com/brightio/penelope.git;

git clone https://github.com/antonioCoco/ConPtyShell.git;

git clone https://github.com/diego-treitos/linux-smart-enumeration.git;

git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git;

git clone https://github.com/pentestpop/autoNTDS.git;

git clone https://github.com/antonioCoco/ConPtyShell.git;

git clone https://github.com/pentestpop/ARMincursore.git;

git clone https://github.com/cddmp/enum4linux-ng.git;

git clone https://github.com/ivan-sincek/php-reverse-shell.git;

git clone https://github.com/arthaud/git-dumper.git;

git clone https://github.com/pentestpop/verybasicenum.git;

git clone https://github.com/nicocha30/ligolo-ng.git;

#Kerbrute part 1
printf '\n============================================================\n'
printf '[+] Building Kerbrute\n'
printf '============================================================\n\n'
git clone https://github.com/ropnop/kerbrute.git;

# NOTE: The next few commands are specific to my preference and should be removed or altered for other users. 
# Kerbrute part 2 - build kerbrute using either arm or AMD (edit Makefile to say 'ARCHS=arm64' & then 'sudo make linux'")
echo "For kerbrute, please choose the ARCHS option:"
echo "1) ARCHS=arm64"
echo "2) ARCHS=amd64"
read -p "Enter your choice (1 or 2): " choice

# Determine the replacement text based on the user's choice
if [ "$choice" == "1" ]; then
    replacement="ARCHS=arm64"
elif [ "$choice" == "2" ]; then
    replacement="ARCHS=amd64 386"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Use sed to replace the second line in the file
sed -i "2s/.*/$replacement/" /opt/kerbrute/Makefile;

#building the kerbrute file
cd /opt/kerbrute/ && make linux;
# cp /opt/kerbrute/dist/kerbrute_linux_arm64 /usr/local/bin/kerbrute; 
# added to bottom (echo "export GOPATH=$HOME/go" >> ~/.zshrc;)
# added to bottom (echo "export PATH=$PATH:/usr/lib/go/bin:$GOPATH/bin" >> ~/.zshrc;) 

# ILSpy - archived so this is always the latest binary
# mkdir /opt/ILSpy;
# wget -P /opt/ILSpy https://github.com/icsharpcode/AvaloniaILSpy/releases/download/v7.2-rc/Linux.arm64.Release.zip;
# unzip /opt/ILspy/Linux.arm64.Release.zip;
# unzip /opt/ILSpy/ILSpy-linux-arm64-Release.zip;
# chmod +x /opt/ILSpy/artifacts/linux-arm64/ILSpy;
# echo "alias ILSpy= '/opt/ILSpy/artifacts/linux-arm64/ILSpy'" >> ~/.zshrc;

## Install BLS-specific tools
# Impacket
curl -LsSf https://astral.sh/uv/install.sh | sh;
export PATH="/home/$USER/.local/bin:$PATH";
uv tool install git+https://github.com/blacklanternsecurity/impacket; 
# NetExec
pipx ensurepath;
pipx install git+https://github.com/blacklanternsecurity/NetExec;
# BBOT
pipx install bbot;

#httpx (https://github.com/projectdiscovery/httpx)
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Bloodhound via Docker
printf '\n============================================================\n'
printf '[+] Setting up Bloodhound on Docker\n'
printf '============================================================\n\n'
usermod -aG docker $USER;
systemctl enable --now docker;
mkdir -p /opt/bloodhoundce && cd /opt/bloodhoundce;
wget -q -O docker-compose.yml https://ghst.ly/getbhce;

#install beloved tools
printf '\n============================================================\n'
printf '[+] Installing some tools:\n'
printf '============================================================\n\n'
apt update
apt install bat code fzf gobuster krb5-user libreoffice nmap onesixtyone plocate remmina rlwrap signal-desktop smbmap sqlmap sublime-text terminator;
# removed autorecon burpsuite enum4linux hekatomb kerberoast name-that-hash peass wpscan
pipx install name-that-hash;

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
    git clone https://github.com/pentestpop/PopScripts.git /opt/PopScripts
    # PopScripts symbolic links
    chmod +x /opt/PopScripts/link.sh && bash /opt/PopScripts/link.sh;
    
    # append custom aliases etc. to .zshrc
    # cat /opt/PopMyKali/zshrc_additions.txt >> ~/.zshrc;
    
    # copy orville.jpg to ~/Pictures/. so you have a test photo
    cp /opt/PopMyKali/images/landscape_wallpaper.jpg $HOME/Pictures/landscape_wallpaper.jpg;
    cp /opt/PopMyKali/images/pop_background_black.svg $HOME/Pictures/pop_background_black.svg;
    cp /opt/PopMyKali/images/orville.jpg $HOME/Pictures/orville.jpg
    
    # create a folder with useful scripts to run a server from
    bash /opt/PopMyKali/servefolder.sh;
    
    # create a symlink for verybasicnamp/vbnmap.sh
    chmod +x /opt/verybasicenum/vbnmap.sh;
    ln -s /opt/verybasicenum/vbnmap.sh /usr/local/bin/vbnmap;
    
    # customize terminator
    pip install requests;
    mkdir -p $HOME/.config/terminator/plugins;
    wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py";
    cp /opt/PopMyKali/dotfiles/themeproject/terminatorconfig ~/.config/terminator/config;
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    
    # Install oh-my-zsh:
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
    # Icons and Themes
    mkdir -p ~/.themes && cd /tmp && wget https://cinnamon-spices.linuxmint.com/files/themes/CBlue.zip && unzip CBlue.zip -d ~/.themes/ && rm /tmp/CBlue.zip && gsettings set org.cinnamon.theme name 'CBlue'
    mkdir -p ~/.icons && cd /tmp && git clone https://github.com/bikass/kora.git && cp -r kora/kora ~/.icons/ && rm -rf kora && gsettings set org.cinnamon.desktop.interface icon-theme 'kora'

else
    echo "Skipping poptimization."
fi

printf '\n============================================================\n'
printf '[+] Unzipping RockYou\n'
printf '============================================================\n\n'
gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null

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
    # Split the ASCII art into lines and iterate over them
IFS=$'\n'       # Set the Internal Field Separator to newline
for line in $octopascii; do
   echo "$line"
   sleep 0.5    # Adjust the sleep duration (in seconds) as needed
done

cat << EOF
## FINAL INSTRUCTIONS ##
1. Create a kerbrute symbolic link by running ' sudo cp /opt/kerbrute/dist/kerbrute\$ /usr/local/bin/kerbrute"
2. Don't forget to run /opt/PopMyKali/servefolder.sh
3. Don't forget to sync firefox with your +kali account!
4. Add this to your .zshrc file if necessary:

export GOPATH=$HOME/go
export PATH=$PATH:/usr/lib/go/bin:$GOPATH/bin
# Alias to start BloodHound
alias bh-start='cd /opt/bloodhoundce && docker-compose up -d'
# Alias to stop BloodHound
alias bh-stop='cd /opt/bloodhoundce && docker-compose stop'
# Alias to see the running containers
alias bh-ps='cd /opt/bloodhoundce && docker-compose ps'

EOF
