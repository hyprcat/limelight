rm -rf /home/ubuntu/LimeLight-Video
#!/bin/bash
# will install the dependencies to run the applications.

#install docker
sudo apt update
yes | sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -


# Update and install dependencies
sudo apt-get update
sudo apt-get install -y build-essential

# Add NVIDIA package repositories
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo sh -c 'echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list'

# Install NVIDIA driver
sudo apt-get update
sudo apt-get -y install cuda-drivers


sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
yes | sudo apt install docker-ce
sudo apt-get install docker-compose

# update user to not require sudo for docker commands
sudo usermod -aG docker ${USER}
su - ${USER}

# install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


sudo mkdir /var/run/celery
sudo chown -R celery:celery /var/run/celery
sudo chmod o+w /var/run/celery


# Add the package repositories
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Update the package lists and install the NVIDIA container toolkit
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker

