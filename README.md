# PopMyKali
A script to install everything I want on a fresh Kali image, inspired by the [PimpMyKali](https://github.com/Dewalt-arch/pimpmykali) script. 

## Basic Usage (PopMyKali)
Clone this repositiory into your `/opt` directory and run ./popmykali.sh. This script will install a bunch of tools I find myself installing each time I create a new Kali VM. They are listed below. Please note that during this installation, the script will prompt you for your VM's architecture for one or more tools:

### Kali Package Manager
I have a script that I run on fresh Kali spinups, and these are the tools I tend to install on top of vanilla Kali. All of these can be installed with `sudo apt install $name`:
- [bat](https://github.com/sharkdp/bat) - improvment on `cat`
- copyq
- docker.io, docker-compose-plugin
- [exploitdb](https://www.kali.org/tools/exploitdb/) - searchable archive from The Exploit Database; provides `searchsploit`
- [feroxbuster](https://www.kali.org/tools/feroxbuster/) - fast, recursive content discovery tool for web application enumeration
- flameshot
- fzf
- [gobuster](https://www.kali.org/tools/gobuster/) - brute-force directories and files in websites, Virtual Host names, and subdomains 
- [golang-go](https://go.dev/) - the Go programming language  
- [libreoffice](https://www.libreoffice.org/) - FOSS office suite 
- [Ligolo-ng](https://www.kali.org/tools/ligolo-ng/) - tunneling/pivoting tool that uses a TUN interface
- [netexec](https://www.kali.org/tools/netexec/) - includes nxc, the updated version of crackmapexec
- [name-that-hash](https://www.kali.org/tools/name-that-hash/)- or nth, a hash identifier through either file or text 
- nmap
- plocate
- [python3-pip](https://www.kali.org/tools/python-pip/#python3-pip) - Python3 package installer
- [python3-venv](https://docs.python.org/3/library/venv.html) - Python3 package for creating virtual environments, in case you need to briefly use some dependencies that might conflict with your installed libraries 
- [rlwrap](https://github.com/hanslub42/rlwrap) - a 'readline wrapper', a small utility that uses the [GNU Readline](https://tiswww.case.edu/php/chet/readline/rltop.html) library to allow the editing of keyboard input for any command, making certain shells more stable/easier to use. 
- [SecLists](https://www.kali.org/tools/seclists/) - wordlists for security testing, installed to `/usr/share/seclists/`
- [smbmap](https://www.kali.org/tools/smbmap/) - allows users to enumerate samba share drives across an entire domain
- [sqlmap](https://www.kali.org/tools/sqlmap/) - automatic SQL injection and database takeover tool
- [terminator](https://gnome-terminator.org/) - a simple to use terminal emulator 
- tree
- [wordlists](https://www.kali.org/tools/wordlists/) - includes rockyou.txt, unzipped to `/usr/share/wordlists/`

#### Lately removed
These have been removed due to changes with bloodhound. 
- [bloodhound](https://www.kali.org/tools/bloodhound/) - (changed to docker version) for visualizing Active Directory information
- [enum4linux](https://www.kali.org/tools/enum4linux/) - a tool for enumerating information from Windows and Samba systems remotely
- [hekatomb](https://www.kali.org/tools/hekatomb/)- a Python script that connects to an LDAP directory to retrieve all computers and users’ information in order to decrypt DPAPI blobs 
- [neo4j](https://neo4j.com/)- graph and database management, you need it to run BloodHound
- [kerberoast](https://www.kali.org/tools/kerberoast/) - for kerberoasting, though you can probably just use a combination of other tools, impacket in particular
- [peass](https://www.kali.org/tools/peass-ng/) - well-known privilege escalation scripts for Windows and Linux (and MacOS)
- pspy - I have been recieving errors even after updating the apt respository
- wsgidav - I have been using other tools
- gcc-go - seemed to have conflicts with golang-go
- [wpscan](https://www.kali.org/tools/wpscan/) - scan a target WordPress URL and enumerate any plugins that are installed
- [wsgidav](https://www.kali.org/tools/wsgidav/)- a generic and extendable WebDAV server
- [autorecon](https://github.com/Tib3rius/AutoRecon) - dropped from the apt install list
- [bloodhound.py](https://www.kali.org/tools/bloodhound.py/) - superseded by BloodHound CE via Docker
- [burpsuite](https://www.kali.org/tools/burpsuite/) - dropped from the apt install list
- [krb5-user](https://packages.debian.org/bullseye/krb5-user) - Kali-specific, not part of the Debian setup
- [onesixtyone](https://www.kali.org/tools/onesixtyone/) - Kali-specific, not part of the Debian setup
- [python3-ldapdomaindump](https://www.kali.org/tools/python-ldapdomaindump/) - dropped from the apt install list
- [remmina](https://remmina.org/) - Kali-specific, not part of the Debian setup
- [sublime-text](https://www.sublimetext.com/) - Kali-specific, not part of the Debian setup; VS Code is installed instead
- [SharpCollection](https://github.com/Flangvik/SharpCollection) - Kali-specific, not cloned by attackbox.sh
- [adPEAS](https://github.com/61106960/adPEAS) - Kali-specific, not cloned by attackbox.sh
- [ConPtyShell](https://github.com/antonioCoco/ConPtyShell) - Kali-specific, not cloned by attackbox.sh
- [Windows Exploit Suggester](https://github.com/AonCyberLabs/Windows-Exploit-Suggester) - Kali-specific, not cloned by attackbox.sh
- [Ivan Sincek Reverse Shell](https://github.com/ivan-sincek/php-reverse-shell) - Kali-specific, not cloned by attackbox.sh


### GitHub
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)- a ton of useful payloads.
- [Penelope](https://github.com/brightio/penelope)- This is a reverse shell listener with some extended functionality like automatically upgrading shells to Python pty shells and additional commands which allow you to upload and download files directly from the shell.
- [LSE](https://github.com/diego-treitos/linux-smart-enumeration) - similar functionality to linpeas, but I personally prefer the output to linpeas. Sometimes I run both, but I always run `lse.sh -l1` first.
- [git-dumper](https://github.com/arthaud/git-dumper) - Dumps git repos from the web, especially useful for those which aren't easily cloned with `git`.
- [verybasicenum](https://github.com/pentestpop/verybasicenum) - My personal custom enumeration scripts. Simpler and faster than winpeas/linpeas though much less detail. I like to run them first, then the more detailed scripts after.
- [Kerbrute](https://github.com/ropnop/kerbrute)- for brute forcing Kerberos.
- [BloodHound-CustomQueries](https://github.com/ZephrFish/Bloodhound-CustomQueries) - a collection of custom Cypher queries for BloodHound.
- [PopScripts](https://github.com/pentestpop/PopScripts) - my custom scripts, symlinked onto `PATH` during poptimization.

### Other Tools
- Signal
- VS Code
- Specific version of Impacket and NXC
- [Metasploit Framework](https://www.kali.org/tools/metasploit-framework/) - installed via the official omnibus installer
- [httpx](https://github.com/projectdiscovery/httpx) - installed via `go install`
- [bbot](https://github.com/blacklanternsecurity/bbot) - installed via `pipx`

## Advanced Usage (Poptimize)
After these tools have been installed, the script will then prompt you for whether you want to poptimize your install. This script contains some additional customizations that I personally find useful but are more specific to me:
1. It clones [PopScripts](https://github.com/pentestpop/PopScripts) a repo which includes custom scripts I use to make my life easier, and creats symbolic links for these scripts. 
2. It also clones my [verybasicenum](https://github.com/pentestpop/verybasicenum), which includes the vanilla nmap script I run on pentest labs as well scripts which run a basic enumeration checklist on target hosts in `.ps1`, `.sh`, and `.bat` formats. It creates a symbolic link for the `vbnmap.sh` so that it can be used with `sudo vbnamp $target`. 
3. It copies sample images to the ~/images directory to be used for testing during for file upload vulnerabilities. 
4. It customizes terminator, a terminal emulator by adding theme functionality, a custom pane setup, and some color changes. 
5. It creates a desktop background.

Skip this if you do not want these customizations. I think the core functionality could be good for anyone, but the `poptimize.sh` script was made for me. 

