#need root user login
#Currently manually run create a nano script.sh then save, bash the script after
USERNAME="#{username}#"
mkdir -p /home/nas/Prechart-Services/AppConfig
sudo chown -R $USERNAME:$USERNAME /home/nas/Prechart-Services/AppConfig
sed -i 's/openssl_conf = openssl_init/#openssl_conf = openssl_init/g' /etc/ssl/openssl.cnf
sudo addgroup --system docker
sudo adduser $USERNAME docker
newgrp docker
apt-get install acl
sudo setfacl -m "g:docker:rw" /var/run/docker.sock