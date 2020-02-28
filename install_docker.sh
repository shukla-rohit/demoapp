#!/bin/bash
sudo apt update

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

sudo apt-get update

apt-cache policy docker-ce

sudo apt install -y docker-ce

# add current user to docker group so there is no need to use sudo when running docker
sudo usermod -aG docker $(whoami)

# add jenkins user to docker group
sudo usermod -aG docker jenkins

sudo systemctl restart docker

# install selenium and pyvirtualdisplay for tesing
sudo apt-get install -y python-pip

sudo pip install selenium

sudo pip install pyvirtualdisplay

sudo apt-get install -y xvfb xserver-xephyr vnc4server

export GV=v0.26.0

wget "https://github.com/mozilla/geckodriver/releases/download/$GV/geckodriver-$GV-linux64.tar.gz"

tar xvzf geckodriver-$GV-linux64.tar.gz 

chmod +x geckodriver

sudo cp geckodriver /usr/local/bin/
