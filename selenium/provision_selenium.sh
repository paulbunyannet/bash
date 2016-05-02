#!/usr/bin/env bash
# @todo make sure script does not return error when installing, right now when running with vagrant up the coding will be "red" which may or may not be classified as an error in Jenkins
# ===================================================
# Start Setup
# ===================================================
cd ~/
# Update yum
sudo yum -y update

# ===================================================
# Start install of the Selenium stack
# * Selenium stand alone server
# * Firefox
# * Xvfb
# ===================================================

# borrowed from https://github.com/seanbuscay/vagrant-phpunit-selenium/blob/master/setup.sh
set -e
if [ -e /.sssInstalled ]; then
  echo 'Already installed.'

else
  echo ''
  echo 'INSTALLING SELENIUM STACK'
  echo '----------'

  # Install Java, firefox, Xvfb, and unzip
  sudo yum -y install java-1.8.0-openjdk-headless.x86_64
  sudo yum -y install xorg-x11-server-Xvfb.x86_64
  sudo yum -y install dbus

  # http://tecadmin.net/install-firefox-on-linux/#
  cd /usr/local
  sudo rm firefox.tar.bz2 || true
  sudo wget -O firefox.tar.bz2 http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/33.0/linux-x86_64/en-US/firefox-33.0.tar.bz2
  sudo tar xvjf firefox.tar.bz2
  sudo rm /usr/bin/firefox || true
  sudo ln -s /usr/local/firefox/firefox /usr/bin/firefox
  sudo rm firefox.tar.bz2
  firefox -v

  # get fonts so that firefox doesn't freak out that it's missing fonts for display
  sudo yum -y install dejavu-lgc-sans-fonts

  # setup machine Id, firefox needs this machine id
  sudo mkdir /var/lib/dbus || true
  sudo touch /var/lib/dbus/machine-id || true
  echo `dbus-uuidgen` | sudo tee /var/lib/dbus/machine-id

  # Download and copy the ChromeDriver to /usr/local/bin
  cd /tmp
  if [ ! -d "/var/selenium" ]; then
    sudo mkdir /var/selenium
  fi
  # get selenium server latest release
  wget -O selenium-server-standalone.jar http://goo.gl/PJUZfa
  sudo mv selenium-server-standalone.jar /var/selenium

  # So that running `vagrant provision` doesn't redownload everything
  sudo touch /.sssInstalled
fi

# ===================================================
# Start Xvfb, firefox, and Selenium in the background
# ===================================================

cd ~/

# do check to see if selenium server is already running
seleniumStatus="http://localhost:4444/selenium-server/driver/?cmd=getLogMessages";
sudo sudo rm /.sss || true
sudo curl ${seleniumStatus} -o /.sss -f || echo -e "SELENUIM NOT RUNNING" | sudo tee /.sss
seleniumRunning=`cat /.sss`
if grep -q OK <<<${seleniumRunning}; then
  echo "Selenium Server is already running, returned '$seleniumRunning'."
else
    # Start up the Selenium Server in the background
  echo "Starting Selenium ..."
  cd /var/selenium
  sudo rm ./selenium.log || true
  sudo touch ./selenium.log
  sudo chmod 777 ./selenium.log
  export DISPLAY=:10
  Xvfb :10 +extension RANDR -screen 0 1366x768x24 -ac -extension RANDR &
  nohup xvfb-run java -jar ./selenium-server-standalone.jar > selenium.log &
fi