#!/bin/bash

# PopScripts
git clone https://github.com/pentestpop/PopScripts.git /opt/PopScripts
# PopScripts symbolic links
chmod +x /opt/PopScripts/link.sh && /opt/PopScripts/link.sh;

# append custom aliases etc. to .zshrc
cat /opt/PopMyKali/zshrc_additions.txt >> ~/.zshrc;

# copy orville.jpg to ~/Pictures/. so you have a test photo
cp /opt/PopMyKali/samples/Sample.jpg ~/Pictures/Sample.jpg;
cp /opt/PopMyKali/samples/Sample.png ~/Pictures/Sample.png;
cp /opt/PopMyKali/samples/orville.jpg ~/Pictures/orville.jpg

# create a folder with useful scripts to run a server from
bash /opt/PopMyKali/servefolder.sh;

# create a symlink for verybasicnamp/vbnmap.sh
chmod +x /opt/verybasicenum/vbnmap.sh;
ln -s /opt/verybasicenum/vbnmap.sh /usr/local/bin/vbnmap;

# customize terminator
pip install requests;
mkdir -p $HOME/.config/terminator/plugins;
wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py";
cp /opt/PopMyKali/terminatorconfig ~/.config/terminator/config;
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
