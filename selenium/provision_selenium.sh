#!/usr/bin/env bash
# @todo make sure script does not return error when installing, right now when running with vagrant up the coding will be "red" which may or may not be classified as an error in Jenkins
# ===================================================
# Start Setup
# ===================================================
cd ~/
# Update yum
sudo yum -y update

cd /tmp
if [ ! -d "/var/selenium" ]; then
sudo mkdir /var/selenium
fi

# ===================================================
# Start install of the Selenium stack
# * Selenium stand alone server
# * Firefox
# * Xvfb
# ===================================================

# borrowed from https://github.com/seanbuscay/vagrant-phpunit-selenium/blob/master/setup.sh
set -e
if [ -e /.sssInstalled ]; then
  echo 'Selenium requirements already installed.'

else
  echo '-------------------------'
  echo 'INSTALLING SELENIUM STACK'
  echo '-------------------------'

  # Install Java, firefox, Xvfb, and unzip
  sudo yum -y install java-1.8.0-openjdk-headless.x86_64
  sudo yum -y install xorg-x11-server-Xvfb.x86_64
  sudo yum -y install dbus
  sudo yum -y install libvpx
  sudo yum -y install firefox
  firefox -v

  # get the latest Chrome web driver
  sudo yum -y install GConf2
  sudo yum -y install unzip
  sudo wget https://chromedriver.storage.googleapis.com/LATEST_RELEASE -O /var/selenium/CHROME_WEBDRIVER_LATEST_RELEASE
  sudo wget https://chromedriver.storage.googleapis.com/$(cat /var/selenium/CHROME_WEBDRIVER_LATEST_RELEASE)/chromedriver_linux64.zip
  sudo unzip chromedriver_linux64.zip
  sudo mv chromedriver /usr/local/bin
  /usr/local/bin/chromedriver -v

  # install the latest chrome
  wget https://raw.githubusercontent.com/paulbunyannet/bash/master/selenium/google-chrome.repo
  sudo mv google-chrome.repo /etc/yum.repos.d
  sudo yum -y install google-chrome-stable

  # get fonts so that firefox doesn't freak out that it's missing fonts for display
  sudo yum -y install dejavu-lgc-sans-fonts

  # setup machine Id, firefox needs this machine id
  sudo mkdir /var/lib/dbus || true
  sudo touch /var/lib/dbus/machine-id || true
  echo `dbus-uuidgen` | sudo tee /var/lib/dbus/machine-id

  # get selenium server latest release
  echo "Download latest selenium server..."
  wget -O selenium-server-standalone.jar http://goo.gl/IHP6Qw
  chown vagrant:vagrant selenium-server-standalone.jar
  sudo mv selenium-server-standalone.jar /usr/local/bin

  # So that running `vagrant provision` doesn't redownload everything
  sudo touch /.sssInstalled
fi

# ===================================================
# Start Xvfb, chrome, and Selenium in the background
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
  echo '-------------------------'
  echo "Starting Selenium ..."
  echo '-------------------------'
  cd /var/selenium
  sudo touch ./selenium.log
  sudo chmod 777 ./selenium.log
  export DISPLAY=:10
  Xvfb :10 +extension RANDR -screen 0 1366x768x24 -ac -extension RANDR &
  google-chrome --remote-debugging-port=9222 &
  nohup xvfb-run java -Dwebdriver.chrome.driver=/usr/local/bin/chromedriver -jar /usr/local/bin/selenium-server-standalone.jar > selenium.log &
  echo '-------------------------'
  echo "Selenium Server Started!"
  echo '-------------------------'
fi