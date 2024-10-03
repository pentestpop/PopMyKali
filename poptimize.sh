#!/bin/bash

# PopScripts
git clone https://github.com/cagrigsby/PopScripts.git /opt/.
# PopScripts symbolic links
sudo chmod +x /opt/PopScripts/link.sh && sudo /opt/PopScripts/link.sh;

# append custom aliases etc. to .zshrc
cat /opt/PopMyKali/zshrc_additions.txt >> ~/.zshrc;

# copy orville.jpg to ~/Pictures/. so you have a test photo
cp /opt/PopMyKali/orville.jpg ~/Pictures/orville.jpg;

# create a folder with useful scripts to run a server from
/opt/PopScripts/servefolder.sh;

# customize terminator
pip3 install requests;
mkdir -p $HOME/.config/terminator/plugins;
wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py";
cp /opt/Kali_JumpStart/terminatorconfig ~/.config/terminator/config;
echo " Solarized Dark - Patched is a decent template for terminator";

# To add a white text on blue background for your terminal, add this to .zshrc:
echo "PS1='%{\$(tput setab 4)\$(tput setaf 7)%}%(#.\$USER.\$USER)@%m%{\$(tput sgr0)%}-%{\$(tput setaf 4)%}-%{\$(tput sgr0)%}[%~]%{\$(tput sgr0)%}\$ '" >> ~/.zshrc;

# Set the wallpaper
# Set the wallpaper image (assuming you want a wallpaper, otherwise skip this part)
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "/opt/PopMyKali/popsonder.svg"

# Set the wallpaper style (stretched)
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -s 2

# Set the primary color (left side) to #007acc
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/rgba1 -t double -t double -t double -t double -s 0.0 -s 0.478 -s 0.8 -s 1.0

# Set the secondary color (right side) to #f686bd
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/rgba2 -t double -t double -t double -t double -s 0.965 -s 0.525 -s 0.741 -s 1.0

# Set the color style to a horizontal gradient
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/color-style -s 2


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
