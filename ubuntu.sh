#!/usr/bin/env bash
USER=$(whoami)
export DEBIAN_FRONTEND=noninteractive
export PATH="$HOME/.local/bin:$PATH"
sudo rm -rf /var/lib/dpkg/lock
sudo rm -rf /var/cache/debconf/*.*

# colors
NORMAL=`tput sgr0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
Done="${GREEN}Done ✓${NORMAL}"

clear
echo "${RED}Disclaimer:${NORMAL} This script is bloated"
sleep 5

echo "${RED}Do you want to change server password?${NORMAL}"
read -p "y/n:
" prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  sudo passwd $USER
else
  echo "${GREEN}Password wasn't Changed.${NORMAL}"
fi


echo "${RED}Enabling Universe, Multiverse and Restricted repositories${NORMAL}"
sleep 1
sudo add-apt-repository universe > /dev/null
sudo add-apt-repository multiverse > /dev/null
sudo add-apt-repository restricted > /dev/null
echo $Done

echo "${RED}Checking for updates.${NORMAL}"
sleep 1
sudo apt-get -y update > /dev/null
sudo apt-get -y upgrade > /dev/null 2>&1
sudo apt-get -y autoremove  > /dev/null
echo $Done

echo "${RED}Setting UTF8${NORMAL}"
sleep 1
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
sudo apt-get install -qq language-pack-en-base > /dev/null
sudo apt-get install -qq software-properties-common > /dev/null
echo $Done

echo "${RED}Adding a auto updater to crontab${NORMAL}"
sleep 1
sudo crontab -l > updater
sudo echo "0 0 * * *    sudo apt-get update && sudo apt-get upgrade -y && sudo apt autoremove && echo updated@SUCCESS >> ~/.update.log" >> updater
sudo crontab updater
sudo rm updater
echo $Done

echo "${RED}Installing Apt-fast${NORMAL}"
sudo add-apt-repository -y ppa:apt-fast/stable > /dev/null
sudo apt-get -qq update > /dev/null && sudo DEBIAN_FRONTEND=noninteractive apt-get -y install apt-fast > /dev/null 
echo $Done

echo "${RED}Installing day2day packages${NORMAL}"
sudo apt-get install -qq ncdu tmux irssi tree rar unrar zip unzip htop atop p7zip-full neovim vnstati bat > /dev/null 2>&1
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat > /dev/null 2>&1

echo $Done

echo "${RED}Now installing some python essential packages${NORMAL}"
sudo apt-get install -qq python3-pip python3-dev python3-utmp python3-virtualenv  > /dev/null 2>&1
pip install bs4 youtube-dl gallery-dl python-dateutil requests setuptools botocore oauthlib  docutils requests-oauthlib tqdm pytest wheel urllib3 > /dev/null 2>&1
echo $Done

echo "${RED}Installing rclone${NORMAL}"
sleep 1
curl -s https://rclone.org/install.sh | sudo bash > /dev/null 2>&1
echo $Done

echo "${RED}Installing a good vimrc${NORMAL}"

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime > /dev/null 2>&1
sh ~/.vim_runtime/install_awesome_vimrc.sh > /dev/null 2>&1
echo $Done

echo "${RED}Installing vsftpd${NORMAL}"
sudo apt-get install -qq vsftpd  > /dev/null
sudo systemctl start vsftpd  > /dev/null 2>&1
sudo systemctl enable vsftpd > /dev/null 2>&1
sudo tee -a /etc/vsftpduserlist.conf >> /dev/null <<'user'
ubuntu
root
user
sudo systemctl restart vsftpd  > /dev/null 2>&1
echo $Done

echo "${RED}Installing some compiling packages${NORMAL}"
sudo apt-get install -qq build-essential libssl-dev autoconf automake cmake ccache libicu-dev git-core libass-dev zlib1g-dev yasm texinfo pkg-config libtool > /dev/null 2>&1
echo $Done

echo "${RED}Installing ffmpeg, please refer to https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu for extra codecs${NORMAL}"
sleep 5
sudo apt-get install -qq ffmpeg > /dev/null 2>&1
echo $Done

echo "${RED}Installing Language packages${NORMAL}"
sudo add-apt-repository -y ppa:openjdk-r/ppa > /dev/null
sudo add-apt-repository -y ppa:linuxuprising/libpng12 > /dev/null # I am skipping php due to reasons and only adding its repo in case there is a need to install it.
sudo apt-get install -qq nginx golang perl openjdk-15-jre > /dev/null 2>&1 
curl -sL https://deb.nodesource.com/setup_current.x | sudo -E bash - > /dev/null && sudo apt-get -y install nodejs > /dev/null
echo $Done # sudo apt-get install -qq curl debconf-utils php-pear php7.4-curl php7.4-dev php7.4-gd php7.4-mbstring php7.4-zip php7.4-mysql php7.4-xml php7.4-fpm php7.4-intl php7.4-bcmath > /dev/null 
 
#echo "${RED}Installing aria2 & transmission${NORMAL}"
sudo apt-get install -qq aria2 > /dev/null
#sudo apt-get install -qq transmission-cli transmission-daemon > /dev/null && sudo /etc/init.d/transmission-daemon stop > /dev/null && mkdir ~/downloads && sudo chown ubuntu:debian-transmission ~/downloads && sudo chmod g+w ~/downloads && clear && sudo sed -i 's|"/var/lib/transmission-daemon/downloads"|"~/downloads"|g' /etc/transmission-daemon/settings.json && sudo sed -i 's|"rpc-whitelist-enabled": true|"rpc-whitelist-enabled": false|g' /etc/transmission-daemon/settings.json && sudo sed -i 's|"rpc-authentication-required": true|"rpc-authentication-required": false|g' /etc/transmission-daemon/settings.json > /dev/null
#echo $Done
# not installing but kept in the code for future purposes

echo "${RED}changing MOTD${NORMAL}" # "touch .hushlogin" to "remove" the motd instead of deleting it.
sudo apt-get install -qq update-motd > /dev/null
sudo rm -rf /etc/update-motd.d/*
sudo apt-get install -qq inxi screenfetch > /dev/null
sudo touch /etc/update-motd.d/01-custom 
sudo chmod +x /etc/update-motd.d/01-custom

sudo tee /etc/update-motd.d/01-custom > /dev/null <<'MOTD'
#!/bin/bash
echo GENERAL SYSTEM INFORMATION
/usr/bin/screenfetch
echo
echo SYSTEM DISK USAGE
export TERM=xterm; inxi -D
echo
MOTD
echo $Done

echo "${RED}Now installing oh-my-tmux${NORMAL}"
cd && git clone --quiet https://github.com/gpakosz/.tmux.git > /dev/null && ln -s -f .tmux/.tmux.conf > /dev/null && cp .tmux/.tmux.conf.local . 
echo $Done

echo "${RED}Now installing ZSH${NORMAL}"
sleep 1
sudo apt-get update -qq && sudo apt-get install -qq zsh > /dev/null 2>&1 && \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
echo -e "${GREEN}Making Oh My Zsh hawt...${NORMAL}"
git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting > /dev/null 
git clone --quiet https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions > /dev/null 
git clone --quiet https://github.com/zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions > /dev/null 
wget https://raw.githubusercontent.com/rupa/z/master/z.sh -q -O ~/.z > /dev/null 2>&1
git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k > /dev/null
[[ -z $(grep "autoload -U compinit && compinit" $HOME/.zshrc) ]] && echo "autoload -U compinit && compinit" >> $HOME/.zshrc
	
sed -i '/^ZSH_THEME=/c\ZSH_THEME="random"' $HOME/.zshrc
sed -i '/^plugins=*=/c\plugins=(command-not-found tmux tmuxinator jump z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' $HOME/.zshrc
echo "export PATH=\"/home/$USER/.local/bin:\$PATH\"" >> ~/.zshrc 
sudo tee -a $HOME/.zshrc >> /dev/null <<'ALIAS'
##############
#  A L I A S #
##############
alias py="python3"
alias n="nano"
alias nv="nvim"
alias nnao="nano"
alias pip="pip3"
alias s="sudo"
alias update="sudo apt-get update"
alias upgrade="sudo apt-get -y upgrade"
alias install="sudo apt-get -y install"
alias reboot="sudo reboot"
alias cls="clear"
alias lsd="ls"
alias mount="rclone mount"
alias rm="sudo rm -rf"
alias mkd="mkdir"
alias ytdl="youtube-dl"
alias gdl="gallery-dl"
alias git-push-all="git add * -f && git commit -m \"pushed\""
alias aria2="aria2c"
alias refresh="source ~/.zshrc"
ALIAS


#sudo chsh -s /bin/zsh $USER
sudo echo "bash -c zsh" >> .bashrc # This is used since for some cloud service changing the shell isn't permitted so a work around for it.
echo $Done

echo "${GREEN}ALL DONE!${NORMAL}"
echo "${GREEN}It is recommended to ${RED}reboot${NORMAL}${GREEN} your server now!${NORMAL}"
