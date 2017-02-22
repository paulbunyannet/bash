##Docker and components

###What is in it?
+ .env.example that you may need to change to .env (without the .env file the docker-compose up wont work correctly.)
+ Dockerfile.httpd and php.ini makes the docker-compose up change locations and other info to what we are used to.
+ Dockerfile has the basic configuration for the base layer of our whole app
+ docker-compose has the extra information and configuration of the rest of the app(PHP, mysql, selenium, etc)
+ install.sh and the start.sh are slightly modified from the original files but fitting the new docker config.
+ docker-start.sh, last but not least, this file has many option and settings that depend of all previous files plus composer, gulp, bower, npm, and other which wont break the app, they would just not run

##What is so cool about the docker-start.sh file.
###Well it is cool if you use a mac for development :)

+ if you run:
+ ./docker-start.sh 
..+  you will start the whole docker application
..+ first it will check if you have traefik running, if not, it will run it for you, but if no image is found, it will go and pull the version Nelson created and run it for you. 
..+ second it will ask you if you want to build the images, it would be smart if you dont have the images and or you change something in the images to say yes :)
..+ third it will ask you if you want to download and update all dependencies+ Again unless you have all your dependencies updated to say yes here as well


