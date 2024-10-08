#This is a working draft for creating a folder useful binaries to transfer to a target
mkdir ~/server;
cd ~/server;
#This section downloads the latest precompiled releases from the named repo and binary
#!/bin/bash

#Colors
# Define color codes
PINK='\033[35m'
RESET='\033[0m'

# Define repositories and their binary filenames here
# Format: "owner/repo binary_filename"
repositories=(
    "DominicBreuker/pspy pspy64"
    "peass-ng/PEASS-ng winPEASx64.exe"
    "peass-ng/PEASS-ng winPEASx86.exe"
    "nicocha30/ligolo-ng ligolo-ng_agent_0.7.2-alpha_windows_amd64.zip"
    "nicocha30/ligolo-ng ligolo-ng_agent_0.7.2-alpha_linux_amd64.tar.gz"
    "faustinoaq/sswws ssws.zip"
)

# Function to download the latest binary
download_latest_binary() {
    local repo=$1
    local binary_name=$2

    # Fetch the latest release info
    release_info=$(curl -s "https://api.github.com/repos/$repo/releases/latest")

    # Extract all download URLs
    urls=$(echo "$release_info" | grep "browser_download_url" | cut -d '"' -f 4)

    # Find the exact URL that matches the binary name
    download_url=$(echo "$urls" | while read -r url; do
        filename=$(basename "$url")
        if [[ "$filename" == "$binary_name" ]]; then
            echo "$url"
            break
        fi
    done)

    if [ -n "$download_url" ]; then
        # Download the binary
        echo "Downloading $binary_name from $download_url"
        wget -O "$binary_name" "$download_url"
    else
        echo "${PINK}No exact match found for $binary_name in repository $repo ${RESET}"
    fi
}

# Loop over each repository and download the latest binary
for entry in "${repositories[@]}"; do
    repo=$(echo "$entry" | awk '{print $1}')
    binary_name=$(echo "$entry" | awk '{print $2}')
    download_latest_binary "$repo" "$binary_name"
done


# This section moves existing kali binaries to the appropriate server
cp /usr/share/windows-resources/powersploit/Privesc/PowerUp.ps1 ~/server;
cp /usr/share/windows-resources/binaries/nc.exe ~/server/nc.exe;
cp /usr/share/windows-resources/mimikatz/x64/mimikatz.exe ~/server/mimikatz64.exe;
cp /opt/linux-smart-enumeration/lse.sh ~/server/lse.sh;
cp /usr/share/peass/linpeas/linpeas.sh ~/server/linpeas.sh;
cp /usr/share/windows-resources/powersploit/Privesc/PowerUp.ps1 ~/server/PowerUp.ps1;
cp /opt/ConPtyShell/Invoke-ConPtyShell.ps1 ~/server/Invoke-ConPtyShell.ps1;
cp /opt/verybasicenum/vbenum.bat ~/server/vbenum.bat;
cp /opt/verybasicenum/vbenum.ps1 ~/server/vbenum.ps1;
cp /opt/verybasicenum/vbenum.sh ~/server/vbenum.sh;

#create a test file
echo test > ~/server/test.txt;
