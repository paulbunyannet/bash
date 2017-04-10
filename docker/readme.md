##Docker and components

###What is in it?
+ .env.example that you may need to change to .env (without the .env file the docker-compose up wont work correctly.)
+ Dockerfile.httpd and php.ini makes the docker-compose up change locations and other info to what we are used to.
+ Dockerfile has the basic configuration for the base layer of our whole app
+ docker-compose has the extra information and configuration of the rest of the app(PHP, mysql, selenium, etc)
+ install.sh and the start.sh are slightly modified from the original files but fitting the new docker config.
+ dock.sh, last but not least, this file has many option and settings that depend of all previous files plus composer, gulp, bower, npm, and other which wont break the app, they would just not run
+ options in your .env file

            + doc_npm="true" or "false"/do not write it in your env file
            + doc_composer="true" or "false"/do not write it in your env file
            + doc_yarn="true" or "false"/do not write it in your env file
            + doc_migrate="true" or "false"/do not write it in your env file
            + doc_bower="true" or "false"/do not write it in your env file
            + doc_gulp="true" or "false"/do not write it in your env file

##What is so cool about the dock.sh file.
###Well it is cool if you use a mac for development :)
##if you run:

#./dock.sh 
+ you will start the whole docker application
1. it will check if you have traefik running, if not, it will run it for you, but if no image is found, it will go and pull the version Nelson created and run it for you. 
2. it will ask you if you want to build the images, it would be smart if you dont have the images and or you change something in the images to say yes :)
3. it will ask you if you want to download and update all dependencies+ Again unless you have all your dependencies updated to say yes here as well
4. And:
        
        1. it will run php artisan migrate
        2. it will run gulp
        3. it will leave open bash into the application container

#./dock.sh -h or --help
+ it will show you all the following commands

#./dock.sh open or -open or --open
1. it will open the php container (call code container now in docker-compose file)
2. it will run all the other container if they aren't running
3. it won't rebuild the images and it won't update dependencies
4. And:
        
        1. it will run php artisan migrate
        2. it will run gulp
        3. it will leave open bash into the application container

#./dock.sh down or -down or --down
1. it will do a docker-compose down for all the docker containers that were created from the docker-compose file (traefik is not on that file so it will be still available for other projects that are still open)

#./dock.sh forcedown or fdown or -forcedown or -fdown or --forcedown or --fdown
1. it will do a docker-compose down -v for all the docker containers that were created from the docker-compose file and it will remove their volumes (traefik is not on that file so it will be still available for other projects that are still open)

#./dock.sh -v or --verbose
1. it will do the same than the ./docker-start without any flags but it will give you detail information of what is going on at every turn.
2. And:
        
        1. it will run php artisan migrate
        2. it will run gulp
        3. it will leave open bash into the application container

#./dock.sh -i or --images
1. it will rebuild the images of the container ( you need to have done ./docker-start down first or not have the containers running)
2. it will run the docker-start file without prompting you if you want to build the images by auto answering YES
3. it may asked you if you want to redownload dependencies unless you sent a second flag
4. And:
        
        1. it will run php artisan migrate
        2. it will run gulp
        3. it will leave open bash into the application container

#./dock.sh -ni or --notImages
1. it will run the docker-start file without prompting you if you want to build the images by auto answering NO
2. it may asked you if you want to redownload dependencies unless you sent a second flag
3. And:
        
        1. it will run php artisan migrate    
        2. it will run gulp
        3. it will leave open bash into the application container

#./dock.sh -D or --dependencies
1. it will reinstall all dependencies
2. it will run the docker-start file without prompting you if you want to redownload the dependencies by auto answering YES
3. it may asked you if you want to rebuild images unless you sent a second flag
4. And:
        
        1. it will run php artisan migrate
        2. it will run gulp
        3. it will leave open bash into the application container

#./dock.sh -nd or --notDependencies
1. it will run the docker-start file without prompting you if you want to redownload the dependencies by auto answering NO
3. it may asked you if you want to rebuild images unless you sent a second flag
4. And:
        
        1. it will run php artisan migrate
        2. it will run gulp
        3. it will leave open bash into the application container


#./dock.sh -a or --all
1. it will run the docker-start file without prompting you at anytime, it will rebuild images and redownload the dependencies (it will answer yes to both prompts)
2. And:

        1. it will run php artisan migrate
        2. it will run gulp
        3. it will leave open bash into the application container

#./dock.sh -n or --none
1. it will run the docker-start file without prompting you at anytime, it will not rebuild images or redownload the dependencies (it will answer no to both prompts)
2.  And:

        1. it will run php artisan migrate
        2. it will run gulp
        3. it will leave open bash into the application container

---
> for the flags, you can use up to three flags lets say.
this are a few of the possible combinations but have in mind:
1. if you send a -a/--all or -n/--none.

        1. you can only send a second flag.
        2. this command will only be taken as valid if sent as a first option 
        3. the second flag can only be verbose (you can send one flag instead of two if you dont want the verbose command)
2. if you choose any of all the other options you can send up to 3 flags in any order.

        1. the second flag will allways overwrite the first if you send an oppose command 
                * as -i -ni, in this case not images will be the final argument
        2. the third flag will allways overwrite the first and/or the second command if you send an oppose command 
                * as -i -nd -ni, in this case not images will be the final argument
                * as -ni -i -ni, in this case not images will be the final argument
3. the flags could be: (remember, the order of the flags doens't matter unless you send -a or -n :P )
        
        _____________________________________________________________________________________________________________
        | Flag1 | Flag2 | Flag3 | Result                                                                            |
        _____________________________________________________________________________________________________________
        | `-i`  | `-d`  |       | **create new images and download dependencies**                                   |
        _____________________________________________________________________________________________________________
        | `-i`  | `-d`  | `-v`  | **create new images, download dependencies and show me every message **           |
        |       |       |       | **thought the installation**                                                      |
        _____________________________________________________________________________________________________________
        | `-i`  | `-nd` |       | **create new images and don't download dependencies**                             |
        _____________________________________________________________________________________________________________
        | `-i`  | `-nd` | `-v`  | **create new images, don't download dependencies and show me every message**      |
        |       |       |       | **thought the installation**                                                      |
        _____________________________________________________________________________________________________________
        | `-ni` | `-d`  |       | **don't create new images and download dependencies**                             |
        _____________________________________________________________________________________________________________
        | `-ni` | `-d`  | `-v`  | **don't create new images, download dependencies and show me every message**      |
        |       |       |       | **thought the installation**                                                      |
        _____________________________________________________________________________________________________________
        | `-ni` | `-nd` |       | **don't create new images and don't download dependencies**                       |
        _____________________________________________________________________________________________________________
        | `-ni` | `-nd` | `-v`  | **don't create new images, don't download dependencies but show me every message**|
        |       |       |       | **thought the installation**                                                      |
        _____________________________________________________________________________________________________________
        | `-a`  |       |       | **create new images and download dependencies**                                   |
        _____________________________________________________________________________________________________________
        | `-a`  | `-v`  |       | **create new images, download dependencies and show me every message**            |
        |       |       |       | **thought the installation**                                                      |
        _____________________________________________________________________________________________________________
        | `-n`  |       |       | **don't create new images and don't download dependencies**                       |
        _____________________________________________________________________________________________________________
        | `-n`  | `-v`  |       | **don't create new images, don't download dependencies but show me every message**|
        |       |       |       | **thought the installation**                                                      |
        _____________________________________________________________________________________________________________


---
#Common errors
##Container names are not correct or not found. 

> Check if you have all your variables in your .env file (at least the ones concerning your docker application.)
> Check if you have quotations around your variables values
> It may look pretty but Shell sometimes will give you errors if you leave spaces between the "=" and the variable
name and/or the value 
>> Correct way variable="value"
>> Incorrect way variable = "value" or variable ="value" or variable= "value"