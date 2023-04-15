#!/bin/bash
#Currently manually run create a nano script.sh then save, bash the script after
echo "----------------Start updating and install ssh, dpkg----------------"
sudo apt install openssh-server
sudo ufw allow ssh
sudo apt-get update
sudo apt-get -y install dpkg
sudo dpkg --configure -a

echo "----------------End updating and install ssh, dpkg----------------"

echo "----------------Start curl and ssl install----------------"
sudo apt-get install  ca-certificates  curl  gnupg lsb-release
sudo add-apt-repository ppa:rael-gc/rvm 
sudo mkdir -p /etc/apt/keyrings
echo "----------------End curl and ssl install----------------"

echo "----------------Start docker install----------------"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
echo "----------------End docker install----------------" 

echo "----------------Start other install----------------"
sudo apt install libssl1.0-dev
sudo apt install git
echo "----------------End others install----------------"
echo "----------------Change password root user----------------"
echo "----------------Enter new password for root----------------"
echo "----------------And confirm password ----------------"
sudo passwd