#!/bin/bash

#install tools
echo "Let's get it poppin";

apt update;

apt full-upgrade -y;

#install beloved binaries
sudo apt install autorecon bloodhound burpsuite enum4linux gccgo-go gobuster golang golang-go hekatomb kerberoast krb5-user libreoffice neo4j netexec nth onesixtyone peass pspy python3-pip python3-venv remmina rlwrap smbmap sublime-text terminator wpscan wsgidav;

#install github repositories
cd /opt;

git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git;

git clone https://github.com/21y4d/nmapAutomator.git;

git clone https://github.com/pentestmonkey/unix-privesc-check.git;

git clone https://github.com/Flangvik/SharpCollection.git;

git clone https://github.com/61106960/adPEAS.git;

git clone https://github.com/brightio/penelope.git;

git clone https://github.com/antonioCoco/ConPtyShell.git;

git clone https://github.com/diego-treitos/linux-smart-enumeration.git;

git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git;

git clone https://github.com/cagrigsby/autoNTDS.git;

git clone https://github.com/antonioCoco/ConPtyShell.git;

git clone https://github.com/cagrigsby/ARMincursore.git;

git clone https://github.com/cddmp/enum4linux-ng.git;

git clone https://github.com/ivan-sincek/php-reverse-shell.git;

git clone https://github.com/arthaud/git-dumper.git;

#Kerbrute part 1
git clone https://github.com/ropnop/kerbrute.git;

# NOTE: The next few commands are specific to my preference and should be removed or altered for other users. 
# Kerbrute part 2 - build kerbrute using either arm or AMD (edit Makefile to say 'ARCHS=arm64' & then 'sudo make linux'")
echo "For kerbrute, please choose the ARCHS option:"
echo "1) ARCHS=arm64"
echo "2) ARCHS=amd64 386"
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
sudo sed -i "2s/.*/$replacement/" /opt/kerbrute/Makefile;

#building the kerbrute file
cd /opt/kerbrute && sudo make linux;

# Ask the user if they want to run the other script
echo "Would you like to optimize your Kali with aliases, terminator config, and PopScripts? Y/N"
read -p "Enter your choice: " user_input

# Convert input to lowercase and check if it's 'y' or 'yes'
if [[ "$user_input" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    echo "Running the optimization script..."
    # Replace 'optimize_script.sh' with the actual path to the script you want to run
    sudo ./poptimize.sh
else
    echo "Skipping optimization."
fi


# PopScripts
git clone https://github.com/cagrigsby/PopScripts.git /opt/.
# PopScripts symbolic links
sudo chmod +x /opt/PopScripts/link.sh && sudo /opt/PopScripts/link.sh;

# append custom aliases etc. to .zshrc
cat /opt/PopMyKali/zshrc_additions.txt >> ~/.zshrc

# customize terminator
pip3 install requests;
mkdir -p $HOME/.config/terminator/plugins;
wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py";
cp /opt/Kali_JumpStart/terminatorconfig ~/.config/terminator/config;
echo " Solarized Dark - Patched is a decent template for terminator";

# To add a white text on blue background for your terminal, add this to .zshrc:
echo "PS1='%{\$(tput setab 4)\$(tput setaf 7)%}%(#.\$USER.\$USER)@%m%{\$(tput sgr0)%}-%{\$(tput setaf 4)%}-%{\$(tput sgr0)%}[%~]%{\$(tput sgr0)%}\$ '" >> ~/.zshrc;

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
    sleep 0.2    # Adjust the sleep duration (in seconds) as needed
done

echo " But wait! There\'s more!";
echo " Don't forget to sync firefox with your +kali account!";
echo " Oh wait, one last thing - let's run updatedb so locate works properly.";
updatedb;
echo " Hope that all worked!"