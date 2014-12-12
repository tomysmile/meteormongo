#!/bin/bash
#

if ! test -f .updated_apt_get; then
  # Add repo for mongo db
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list

  echo 'Updating and installing ubuntu packages...'
  # Do actual update packages
  apt-get -y update

  touch .updated_apt_get
fi

if ! test -f .tools_provisioned; then
  echo 'Installing supporting tools...'
  apt-get -y install git curl build-essential

  touch .tools_provisioned
fi

# Install mongodb
dpkg -s mongodb-org &>/dev/null || {
  apt-get -y install mongodb-org=2.6.6 mongodb-org-server=2.6.6 mongodb-org-shell=2.6.6 mongodb-org-mongos=2.6.6 mongodb-org-tools=2.6.6

  rm -rf /etc/mongod.conf
  cp -r  /vagrant/config/mongodb.config /etc/mongod.conf

  service mongod restart
}

# Set running user
run_env=$1
run_as_user=$2

# Install NodeJS via NVM
NVM_DIR="/home/$run_as_user/.nvm";

if [ ! -d $NVM_DIR ]; then
  echo "Installing Node via NVM..."
  export HOME=/home/$run_as_user
  git clone https://github.com/creationix/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`

  echo "source ~/.nvm/nvm.sh" >> /home/$run_as_user/.bashrc
  source /home/$run_as_user/.nvm/nvm.sh

  nvm install 0.10
  #nvm install 0.11
  nvm use stable

  # Set Environment Varaibles
  echo "Setting environment variables..."
  echo "export NODE_ENV=$run_env" >> /home/$run_as_user/.bashrc
  echo "cd /$run_as_user" >> /home/$run_as_user/.bashrc
fi

# NPM package install
command -v grunt &>/dev/null || {
  echo 'Installing grunt-cli, bower ...'
  npm install -g grunt-cli bower
}

# Install meteor
command -v meteor &>/dev/null || {
  echo "Installing meteor..."
  sudo -u $run_as_user -i sh -c 'curl https://install.meteor.com/ | sh'
}

# Clean up permissions
chown -R $run_as_user:$run_as_user /home/$run_as_user/.nvm

# Reset back
export HOME=/home/root
