#!/usr/bin/env bash
USER=$(whoami)
export DEBIAN_FRONTEND=noninteractive

echo "This script is shit and bloated"
sleep 5
clear

echo "Do you want to change server password?"
read -p "y/n:
" prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  sudo passwd $USER
else
  echo "Password wasn't Changed."
fi



# Enable multiverse repository
sudo sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
sudo apt-get -y update
sudo apt-get -y upgrade 
sudo apt-get -y autoremove
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
	
clear
echo "adding a auto updater to crontab"
sleep 1
crontab -l > updater
echo "0 0 * * *		 sudo apt-get update && sudo apt-get upgrade -y && sudo apt autoremove && echo updated@SUCCESS >> ~/.update.log" >> updater
crontab updater
rm updater
clear

echo ################################################
echo "Now we are gonna install all esential packages"
sudo add-apt-repository -y ppa:apt-fast/stable 
sudo apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-fast && echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections && echo debconf apt-fast/dlflag boolean true | debconf-set-selections && echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections

sudo apt-get -y install ncdu tree rar unrar zip unzip htop atop p7zip-full neovim vnstati
clear && sleep 1

echo "Now installing python stuff"
sudo apt-get -y install python3-pip python3-dev python3-utmp python3-virtualenv 
sudo pip3 install virtualenvwrapper wheel gallery-dl youtube-dl requests bs4 lxml 
clear && sleep 1

sudo apt-get -y install tmux irssi 
clear && sleep 1

echo "Installing rclone"
sleep 1
curl https://rclone.org/install.sh | sudo bash
clear && sleep 1

echo "Installing vsftpd"
sudo systemctl start vsftpd
sudo systemctl enable vsftpd
sudo tee -a /etc/vsftpduserlist.conf >> /dev/null <<'user'
ubuntu
towha
root
user

sudo systemctl restart vsftpd
clear && sleep 1

echo "Installing some compiling tools"
sudo apt-get -y install build-essential libssl-dev autoconf automake cmake ccache libicu-dev git-core libass-dev zlib1g-dev yasm texinfo pkg-config libtool 
clear && sleep 1

echo "Installing ffmpeg, please refer to https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu for extra codecs"
sleep 5
sudo apt-get -y install ffmpeg 
clear && sleep 1

echo "installing some more language packages"
echo "skipping php due to reasons" 
sudo apt-get -y install nginx golang docker.io perl default-jre apache2 && curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && sudo apt-get -y install nodejs 
clear && sleep 1
 
echo "Installing aria2,rclone & transmission"
sudo apt-get -y install aria2 
sudo apt-get -y install transmission-cli transmission-daemon 

clear && sleep 1

echo "changing MOTD" # remove this section before running code in case you don't need it
sudo apt-get -y install update-motd
sudo rm -rf /etc/update-motd.d/*
sudo apt-get -y install inxi screenfetch
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
clear && sleep 1

echo "Now installing oh-my-tmux"
cd && git clone https://github.com/gpakosz/.tmux.git && ln -s -f .tmux/.tmux.conf && cp .tmux/.tmux.conf.local .
clear && sleep 1

echo "Now installing ZSH"
sleep 1
sudo apt-get update && sudo apt-get install -y zsh && \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
echo -e "Making Oh My Zsh hawt..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    [[ -z $(grep "autoload -U compinit && compinit" $HOME/.zshrc) ]] && echo "autoload -U compinit && compinit" >> $HOME/.zshrc
	
    sed -i '/^ZSH_THEME=/c\ZSH_THEME="random"' $HOME/.zshrc
	sed -i '/^plugins=*=/c\plugins=(git systemd command-not-found heroku pip tmux tmuxinator jump z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' $HOME/.zshrc
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
alias git-push-all="git add * -f && git commit -m "pushed""
alias aria2="aria2c"
alias refresh="source ~/.zshrc"
ALIAS


sudo chsh -s /bin/zsh $USER
sudo echo "bash -c zsh" >> .bashrc # This is used since for some cloud service changing the shell isn't permitted so a work around for it.
clear && sleep 1

echo "ALL DONE!"
echo "system will now reboot!"
sudo reboot
