#!/bin/sh
# https://stackoverflow.com/a/47204160
# Install assets needed for Lighthouse to function. Run this inside the code container
apt-get install -qq gconf-service libasound2 libatk1.0-0 libcairo2 libcups2 libfontconfig1 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libxss1 fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install
echo "Google version: $(google-chrome-stable --version)"
yarn global add lighthouse
echo "Lighthouse version: $(lighthouse --version)"
# then run:
# lighthouse --chrome-flags="--headless --no-sandbox --ignore-certificate-errors --disable-gpu" --output json --output html --output-path ./tests/_output/lighthouse/report.json https://github.com
# lighthouse --chrome-flags="--headless --no-sandbox --ignore-certificate-errors --disable-gpu" --view https://github.com
