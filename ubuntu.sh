#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
echo "This script is shit and bloated"
sleep 5
clear
# Enable multiverse repository
sudo sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
sudo apt-get -y update
sudo apt-get -y upgrade 
apt-get -qq update
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
	
clear
echo "adding a auto updater to crontab"
sleep 1
crontab -l > updater
echo "0 0 * * *		 sudo apt-get update && sudo apt-get upgrade -y && sudo apt autoremove && echo updated@SUCCESS >> ~/update.log" >> updater
crontab updater
rm updater
clear

echo ################################################
echo "Now we are gonna install all esential packages"
sudo add-apt-repository -y ppa:apt-fast/stable 
sudo apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-fast && echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections && echo debconf apt-fast/dlflag boolean true | debconf-set-selections && echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections
sudo apt-get -y install ncdu tree rar unrar zip unzip htop atop p7zip-full neovim  
clear
sleep 1
echo "Now installing python stuff"
sudo apt-get -y install python3-pip python3-dev python3-utmp python3-virtualenv 
sudo pip3 install virtualenvwrapper wheel gallery-dl youtube-dl requests bs4 lxml 
clear 
sleep 1
sudo apt-get -y install tmux irssi 
echo "Installing rclone"
sleep 1
curl https://rclone.org/install.sh | sudo bash
echo "Installing some compiling tools"
sudo apt-get -y install build-essential libssl-dev autoconf automake cmake ccache libicu-dev git-core libass-dev zlib1g-dev yasm texinfo pkg-config libtool 
clear 
echo "Installing ffmpeg, please refer to https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu for extra codecs"
sleep 5
sudo apt-get -y install ffmpeg 
echo "installing some more language packages"
echo "skipping php due to reasons" 
sudo apt-get -y install nginx golang docker.io perl 
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get -y install nodejs 
clear 
echo "Installing aria2 & transmission"
sudo apt-get -y install aria2 
sleep 1
sudo apt-get -y install transmission-cli transmission-daemon 
clear 
echo "changing MOTD" # remove this section before running code in case you don't need it
sudo apt-get -y install update-motd
sudo rm -rf /etc/update-motd.d/*
sudo apt-get -y install inxi screenfetch vnstati
sudo touch /etc/update-motd.d/01-custom 
sudo chmod +x /etc/update-motd.d/01-custom

sudo echo '#!/bin/bash'| sudo tee -a /etc/update-motd.d/01-custom
sudo echo "echo "GENERAL SYSTEM INFORMATION"" | sudo tee -a /etc/update-motd.d/01-custom
sudo echo "/usr/bin/screenfetch" | sudo tee -a /etc/update-motd.d/01-custom
sudo echo "echo" | sudo tee -a /etc/update-motd.d/01-custom
sudo echo "echo "SYSTEM DISK USAGE"" | sudo tee -a /etc/update-motd.d/01-custom
sudo echo "export TERM=xterm; inxi -D" | sudo tee -a /etc/update-motd.d/01-custom
sudo echo "echo" | sudo tee -a /etc/update-motd.d/01-custom

clear 

echo "Now installing oh-my-tmux"
cd && git clone https://github.com/gpakosz/.tmux.git && ln -s -f .tmux/.tmux.conf && cp .tmux/.tmux.conf.local .
clear
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
	sed -i '/^plugins=*=/c\plugins=(git z zsh-syntax-highlighting zsh-autosuggestions zsh-completions)' $HOME/.zshrc
	
	echo "##############" >> ~/.zshrc # i am too lazy to make a different file and just manage that for aliases 
	echo "#  A L I A S #" >> ~/.zshrc
	echo "##############" >> ~/.zshrc
	echo alias py='"python3"' >> ~/.zshrc
	echo alias n='"nano"' >> ~/.zshrc
	echo alias nv='"nvim"' >> ~/.zshrc
	echo alias nnao='"nano"' >> ~/.zshrc
	echo alias pip='"pip3"' >> ~/.zshrc
	echo alias s='"sudo"' >> ~/.zshrc
	echo alias update='"sudo apt-get update"' >> ~/.zshrc
	echo alias upgrade='"sudo apt-get -y upgrade"' >> ~/.zshrc
	echo alias install='"sudo apt-get -y install"' >> ~/.zshrc
	echo alias reboot='"sudo reboot"' >> ~/.zshrc
	echo alias cls='"clear"' >> ~/.zshrc
	echo alias lsd='"ls"' >> ~/.zshrc
	echo alias mount='"rclone mount"' >> ~/.zshrc
	echo alias rm='"sudo rm -rf"' >> ~/.zshrc
	echo alias ytdl='"youtube-dl"' >> ~/.zshrc
	echo alias gdl='"gallery-dl"' >> ~/.zshrc
	echo alias git-push-all='"git add * -f && git commit -m "pushed""' >> ~/.zshrc
	echo alias aria2='"aria2c"' >> ~/.zshrc
	echo alias refresh='"source ~/.zshrc"' >> ~/.zshrc
sudo chsh -s /bin/zsh ubuntu # change ubuntu with your user name if the shell doesn't change and run this command again
sleep 1
clear
echo "ALL DONE!~~"
echo "I would recommend rebooting now!"
