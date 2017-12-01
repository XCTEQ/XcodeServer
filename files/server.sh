#!/bin/sh

# Usage : sh server.sh my_xcodeserver_user xcode xip location
#  e.g $ sh server.sh shashi ~/Desktop/Xcode_9.1.xip

XCODE_SERVER_USER=$1
XCODE_XIP_PATH=$2


# Uninstall Homebrew

echo "=======Uninstalling Existing Homebrew==========="

rm -rf /usr/local/Homebrew
rm -rf /usr/local/Caskroom
rm -rf /usr/local/bin/brew

# Uninstall RVM

echo "======= Uninstalling Existing RVM ==========="

rm -rf $HOME/.rvm $HOME/.rvmrc /etc/rvmrc /etc/profile.d/rvm.sh /usr/local/rvm /usr/local/bin/rvm

# Uninstall Existing Xcode

echo "=======Uninstalling Existing Xcode==========="

rm -rf /Applications/Xcode.app
rm -rf /Library/Preferences/com.apple.dt.Xcode.plist
rm -rf ~/Library/Preferences/com.apple.dt.Xcode.plist
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf ~/Library/Application Support/Xcode
rm -rf ~/Library/Developer/
rm -rf ~/Library/Developer/CoreSimulator
rm -rf /Library/Developer/CommandLineTools


# Download Xcode .xip and put it on ~/Documents/directory

echo "=======Checking if Xcode XIP exist in Home directory==========="

xcode_xip_file="$XCODE_XIP_PATH"
if [ -f "$XCODE_XIP_PATH" ]
then
	echo "$XCODE_XIP_PATH found."
else
	echo "$XCODE_XIP_PATH not found."
fi

# Move XIP to Home directory

cp -rf $XCODE_XIP_PATH ~/


# Check Xcode xip file is valid

echo "=======Checking if XIP is valid ==========="

pkgutil --check-signature ~/Xcode*.xip | grep \"Status: signed Apple Software\"

# Install Xcode from the .xip using an Archive Activity

echo "=======Installing Xcode. It may take upto 5 minutes. Be patient ! ==========="

open -FWga "Archive Utility" --args ~/Xcode*.xip

# Move Xcode to Applications

mv ~/Xcode*.app /Applications/

# Accept Xcode Licence Agreeemnt

echo "=======Accepting Xcode Licence Agreement and Installing Packages ==========="

sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept

# Install Mobile Device & Development Package

installer -pkg /Applications/Xcode.app/Contents/Resources/Packages//MobileDevice.pkg -target /
installer -pkg /Applications/Xcode.app/Contents/Resources/Packages/MobileDeviceDevelopment.pkg -target /

# Install Xcode System resource package

installer -pkg /Applications/Xcode.app/Contents/Resources/Packages/XcodeSystemResources.pkg -target /

# Install Xcode additional component

installer -pkg /Applications/Xcode.app/Contents/Resources/Packages/XcodeSystemResources.pkg -target /

# Enable developer mode

DevToolsSecurity -enable

# Set Xcode developer directory

sudo xcode-select -s /Applications/Xcode.app/Contents/Developer/

# Check Swift tool chain is correct

echo "=======Checking if Swift toolchain is correct==========="

swift_toolchain="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift"

if [ -f "$swift_toolchain" ]
then
	echo "You are using correct Swift toolchain"
else
	echo "Swift is not using default toolchain"
fi


# Intall Xcode Command Line Tools

echo "======= Installing Xcode Command Line Tools ==========="

# create the placeholder file that's checked by CLI updates' .dist code
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
# find the CLI Tools update
PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
# install it
softwareupdate -i "$PROD" -v

# Check if Xcode command line tools are installed

echo "Checking Xcode CLI tools"
# Only run if the tools are not installed yet
# To check that try to print the SDK path
xcode-select -p &> /dev/null
if [ $? -ne 0 ]; then
  echo "Xcode CLI tools not found. Installing them..."
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
  PROD=$(softwareupdate -l |
    grep "\*.*Command Line" |
    head -n 1 | awk -F"*" '{print $2}' |
    sed -e 's/^ *//' |
    tr -d '\n')
  softwareupdate -i "$PROD" -v;
else
  echo "Xcode CLI tools OK"
fi


echo "==== Adjusting Default macOS Settings ========"

# Disable spotlight
launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist

# Disable lots of animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write com.apple.dock expose-animation-duration -int 0
defaults write com.apple.dock launchanim -bool false

# Never try to sleep harddrives
systemsetup -setsleep Never
systemsetup -setharddisksleep Never
systemsetup -setcomputersleep Never
systemsetup -setdisplaysleep Never

# System update disable for new macOS
echo "Downloading and installing system updates…"
softwareupdate -i -a - ignore iTunes

# We don't want our system changing on us or restarting to update. Disable automatic updates.
echo "Disable automatic updates…"
softwareupdate --schedule off


exists()
{
  command -v "$1" >/dev/null 2>&1
}

echo "==== Homebrew ========"

if exists brew; then
  echo 'Homebrew exists!'
else
  echo "==== Installing Homebrew.. This might take some time ========"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "==== Homebrew installed Successfully ========"
fi

if exists ansible; then
  echo 'Ansible exists!'
else
  echo "==== Installing required brew packages ========"
  brew install ansible
fi

# # Install Fastlane and supporting Ruby Libraries
#
# echo "==== Setting up Ruby and RVM ========"
#
# curl -sSL https://rvm.io/mpapis.asc | gpg --import -
#
# \curl -sSL https://get.rvm.io | bash -s -- --ignore-dotfiles
#
# echo "source /usr/local/rvm/scripts/rvm" >> ~/.bash_profile
#
# source ~/.bash_profile
#
# rvm get stable --auto-dotfiles
#
# echo "==== Installing Ruby ...... ========"
#
# rvm install 2.4.2
#
# rvm default 2.4.2
#
# echo "==== Making RVM Ruby Default========"
#
# echo "rvm default 2.4.2 " >> ~/.bash_profile
#
# echo "==== Installing Rubygems ========"
# source ~/.bash_profile

sudo gem install fastlane
sudo gem install cocoapods
sudo gem install xcpretty

# Xcode Server Enable

echo "==== Setting Up Xcode Server with given user ========"

xcrun xcscontrol --initialize --build-service-user $XCODE_SERVER_USER

xcrun xcscontrol --health

xcrun xcscontrol --configure-ota-certificate

xcrun xcscontrol --configure-integration-timeout 3600

echo "==== Xcode Server setup is finished and Xcode Server is Ready to use ! ========"

echo "Done"
