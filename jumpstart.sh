#!/bin/bash

#install tools
echo "Let's get it poppin";

apt update;

apt full-upgrade -y;

cd /opt;

git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git;

git clone https://github.com/21y4d/nmapAutomator.git;

git clone https://github.com/pentestmonkey/unix-privesc-check.git;

git clone https://github.com/Flangvik/SharpCollection.git;

git clone https://github.com/61106960/adPEAS.git;

git clone https://github.com/brightio/penelope.git;

git clone https://github.com/antonioCoco/ConPtyShell.git;

ln -s /nmapAutomator/nmapAutomator.sh /usr/local/bin/;

sudo apt install autorecon burpsuite enum4linux flameshot gobuster netexec nth onesistyone peass pspy python3-pip remmina rlwrap smbmap terminator wpscan;

# customize terminator
pip3 install requests;
mkdir -p $HOME/.config/terminator/plugins;
wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py";
cp /opt/Kali_JumpStart/terminatorconfig ~/.config/terminator/config;
echo " Solarized Dark - Patched is a decent template for terminator";

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
    sleep 0.1    # Adjust the sleep duration (in seconds) as needed
done

echo " But wait! There\'s more! To add a white text on blue background for your terminal, add this to .zshrc:";
echo " PS1='%{\$(tput setab 4)\$(tput setaf 7)%}%(#.\$USER.\$USER)@%m%{\$(tput sgr0)%}-%{\$(tput setaf 4)%}-%{\$(tput sgr0)%}[%~]%{\$(tput sgr0)%}\$ '";
echo " And make this custom shortcut: bash -c \'flameshot gui\' or just add Shift+Alt+P to open it.";
echo " Don't forget to sync firefox with your +kali account!";
echo " Hope that all worked!"
