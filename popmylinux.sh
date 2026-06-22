#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo!"
   exit 1
fi
TARGET_USER=${SUDO_USER:-$(logname)}
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

printf '\n============================================================\n'
printf '[+] Let'\''s get it poppin\n'
printf '============================================================\n\n'

# Install Required Utilities
apt update;
apt full-upgrade -y;
apt install apt-transport-https curl docker.io docker-compose git gnupg2 golang-go locate pip pipx python-is-python3 wget zsh

# Adding Repo Keys
## VS Code
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -;
add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main";

#install github repositories
printf '\n============================================================\n'
printf '[+] Installing GitHub repos:\n'
printf '============================================================\n\n'
cd /opt;

git clone https://github.com/pentestpop/verybasicenum.git;

#install beloved tools
printf '\n============================================================\n'
printf '[+] Installing some tools:\n'
printf '============================================================\n\n'
apt update
apt install bat code fzf libreoffice nmap plocate terminator;
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
    cp /opt/PopMyKali/images/landscape_wallpaper.jpg $TARGET_HOME/Pictures/landscape_wallpaper.jpg;
    cp /opt/PopMyKali/images/pop_background_black.svg $TARGET_HOME/Pictures/pop_background_black.svg;
    cp /opt/PopMyKali/images/orville.jpg $TARGET_HOME/Pictures/orville.jpg
    
    # create a symlink for verybasicnamp/vbnmap.sh
    chmod +x /opt/verybasicenum/vbnmap.sh;
    ln -s /opt/verybasicenum/vbnmap.sh /usr/local/bin/vbnmap;
    
    # customize terminator
    pip install requests;
    mkdir -p $TARGET_HOME/.config/terminator/plugins;
    wget https://git.io/v5Zww -O $TARGET_HOME"/.config/terminator/plugins/terminator-themes.py";
    cp /opt/PopMyKali/dotfiles/themeproject/terminatorconfig ~/.config/terminator/config;
    
    
    # Install oh-my-zsh:
    RUNASROOT=1 su - "$TARGET_USER" -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    su - "$TARGET_USER" -c "git clone https://github.com/zsh-users/zsh-autosuggestions $TARGET_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    su - "$TARGET_USER" -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting $TARGET_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    
    # Icons and Themes
    mkdir -p ~/.themes && cd /tmp && wget https://cinnamon-spices.linuxmint.com/files/themes/CBlue.zip && unzip CBlue.zip -d ~/.themes/ && rm /tmp/CBlue.zip && gsettings set org.cinnamon.theme name 'CBlue'
    mkdir -p ~/.icons && cd /tmp && git clone https://github.com/bikass/kora.git && cp -r kora/kora ~/.icons/ && rm -rf kora && gsettings set org.cinnamon.desktop.interface icon-theme 'kora'

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
    # Split the ASCII art into lines and iterate over them
IFS=$'\n'       # Set the Internal Field Separator to newline
for line in $octopascii; do
   echo "$line"
   sleep 0.5    # Adjust the sleep duration (in seconds) as needed
done

cat << EOF
## FINAL INSTRUCTIONS ##
1. Add this to your .zshrc file if necessary:

export GOPATH=$TARGET_HOME/go
export PATH=$PATH:/usr/lib/go/bin:$GOPATH/bin

EOF
