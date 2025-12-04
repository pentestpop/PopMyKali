# PopMyKali
A script to install everything I want on a fresh Kali image, inspired by the [PimpMyKali](https://github.com/Dewalt-arch/pimpmykali) script. 

## Basic Usage (PopMyKali)

Clone this repositiory into your `/opt` directory and run ./popmykali.sh. This script will install a bunch of tools I find myself installing each time I create a new Kali VM. They are listed below. Please note that during this installation, the script will prompt you for your VM's architecture for one or more tools:

### Kali Package Manager
I have a script that I run on fresh Kali spinups, and these are the tools I tend to install on top of vanilla Kali. All of these can be installed with `sudo apt install $name`:
- [autorecon](https://github.com/Tib3rius/AutoRecon) - network reconnaissance tool which performs automated enumeration of services, explicitly written by Tib3rius for CTFs and other penetration testing environments
- [bat](https://github.com/sharkdp/bat) - improvment on `cat`
- [bloodhound.py](https://www.kali.org/tools/bloodhound.py/) - for collecting `.json` files for bloodhound to ingest remotely
- [burpsuite](https://www.kali.org/tools/burpsuite/) - for performing security testing of web applications , through editing HTTP requests for example
- [enum4linux](https://www.kali.org/tools/enum4linux/) - a tool for enumerating information from Windows and Samba systems remotely
- [gccgo-go](https://go.dev/doc/install/gccgo) - a compiler for Go 
- [gobuster](https://www.kali.org/tools/gobuster/) - brute-force directories and files in websites, Virtual Host names, and subdomains 
- [golang-go](https://go.dev/) - the Go programming language 
- [hekatomb](https://www.kali.org/tools/hekatomb/)- a Python script that connects to an LDAP directory to retrieve all computers and users’ information in order to decrypt DPAPI blobs 
- [kerberoast](https://www.kali.org/tools/kerberoast/) - for kerberoasting, though you can probably just use a combination of other tools, impacket in particular 
- [krb5-user](https://packages.debian.org/bullseye/krb5-user) - this package contains the basic programs to authenticate to MIT Kerberos
- [libreoffice](https://www.libreoffice.org/) - FOSS office suite 
- [netexec](https://www.kali.org/tools/netexec/) - includes nxc, the updated version of crackmapexec
- [name-that-hash](https://www.kali.org/tools/name-that-hash/)- or nth, a hash identifier through either file or text 
- [onesixtyone](https://www.kali.org/tools/onesixtyone/) - a simple SNMP scanner, particularly useful for identifying community strings
- [peass](https://www.kali.org/tools/peass-ng/) - well-known privilege escalation scripts for Windows and Linux (and MacOS)
- [pspy](https://www.kali.org/tools/pspy/)- a command line tool designed to snoop on processes without need for root permissions. You'll want to run a binary on target machines.  
- [python3-ldapdomaindump](https://www.kali.org/tools/python-ldapdomaindump/) - Active Directory information dumper via LDAP
- [python3-pip](https://www.kali.org/tools/python-pip/#python3-pip) - Python3 package installer
- [python3-venv](https://docs.python.org/3/library/venv.html) - Python3 package for creating virtual environments, in case you need to briefly use some dependencies that might conflict with your installed libraries 
- [remmina](https://remmina.org/) - an RDP client, alternative to xfreerdp when it didn't want to work for whatever reason
- [rlwrap](https://github.com/hanslub42/rlwrap) - a 'readline wrapper', a small utility that uses the [GNU Readline](https://tiswww.case.edu/php/chet/readline/rltop.html) library to allow the editing of keyboard input for any command, making certain shells more stable/easier to use. 
- [smbmap](https://www.kali.org/tools/smbmap/) - allows users to enumerate samba share drives across an entire domain
- [sublime-text](https://www.sublimetext.com/)- text editor 
- [terminator](https://gnome-terminator.org/) - a simple to use terminal emulator 
- [wpscan](https://www.kali.org/tools/wpscan/) - scan a target WordPress URL and enumerate any plugins that are installed
- [wsgidav](https://www.kali.org/tools/wsgidav/)- a generic and extendable WebDAV server

#### Lately removed
These have been removed due to changes with bloodhound. 
- [bloodhound](https://www.kali.org/tools/bloodhound/) - for visualizing Active Directory information
- [neo4j](https://neo4j.com/)- graph and database management, you need it to run BloodHound
- pspy - I have been recieving errors even after updating the apt respository
- wsgidav - I have been using other tools
- gcc-go - seemed to have conflicts with golang-go


### GitHub
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)- a ton of useful payloads.
- [SharpCollection](https://github.com/Flangvik/SharpCollection) - a ton of useful binaries for Windows privesc like Rubeus, Sharphound, Snaffler, and SweetPotato.
- [adPEAS](https://github.com/61106960/adPEAS) - Winpeas/Linpeas for Active Directory.
- [Penelope](https://github.com/brightio/penelope)- This is a reverse shell listener with some extended functionality like automatically upgrading shells to Python pty shells and additional commands which allow you to upload and download files directly from the shell.
- [ConPtyShell](https://github.com/antonioCoco/ConPtyShell)- a stable reverse shell for Windows.
- [LSE](https://github.com/diego-treitos/linux-smart-enumeration) - similar functionality to linpeas, but I personally prefer the output to linpeas. Sometimes I run both, but I always run `lse.sh -l1` first.
- [Windows Exploit Suggester](https://github.com/AonCyberLabs/Windows-Exploit-Suggester)- it suggest exploits for windows.
- [Ivan Sincek Reverse Shell](https://github.com/ivan-sincek/php-reverse-shell) - My favorite PHP reverse shell, it should be on your machine.
- [git-dumper](https://github.com/arthaud/git-dumper) - Dumps git repos from the web, especially useful for those which aren't easily cloned with `git`.
- [verybasicenum](https://github.com/pentestpop/verybasicenum) - My personal custom enumeration scripts. Simpler and faster than winpeas/linpeas though much less detail. I like to run them first, then the more detailed scripts after.
- [Kerbrute](https://github.com/ropnop/kerbrute)- for brute forcing Kerberos.  

## Advanced Usage (Poptimize)
After these tools have been installed, the script will then prompt you for whether you want to poptimize your install. This script contains some additional customizations that I personally find useful but are more specific to me:
1. It clones [PopScripts](https://github.com/cagrigsby/PopScripts) a repo which includes custom scripts I use to make my life easier, and creats symbolic links for these scripts. 
2. It also clones my [verybasicenum](https://github.com/cagrigsby/verybasicenum), which includes the vanilla nmap script I run on pentest labs as well scripts which run a basic enumeration checklist on target hosts in `.ps1`, `.sh`, and `.bat` formats. It creates a symbolic link for the `vbnmap.sh` so that it can be used with `sudo vbnamp $target`. 
3. It copies sample images to the ~/images directory to be used for testing during for file upload vulnerabilities. 
4. It customizes terminator, a terminal emulator by adding theme functionality, a custom pane setup, and some color changes. 
5. It creates a desktop background.

Skip this if you do not want these customizations. I think the core functionality could be good for anyone, but the `poptimize.sh` script was made for me. 

