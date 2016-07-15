#!/usr/bin/env bash
# restart the clock
SECONDS=0
#log file for output of tests
log="codecept-result.log"

finished=false
touch ${log}
echo -n "" >${log}

# check if terminal-notifier is installed for notifications
if which terminal-notifier >/dev/null; then
    showNotify=true
else
    showNotify=false
    echo "Terminal-notifier is not installed, no notifications will display. Head to https://github.com/julienXX/terminal-notifier for more info."
fi;

failed=$1
# tail the log file to see tests while they run
tail -f ${log} &

# run migrations if artisan command exists
vagrant ssh -c "cd /var/www; if [ -f \"artisan\" ]; then php artisan config:clear && php artisan migrate; fi;" >/dev/null 2>&1

# run tests inside vagrant box
if [[ -n "$failed" ]]; then
    vagrant ssh -c "cd /var/www; php codecept.phar run -g ${failed} --debug" > ${log} 2>&1
else
    vagrant ssh -c "cd /var/www; php codecept.phar clean; php codecept.phar build; php codecept.phar run -v --coverage-html --coverage-xml;" > ${log} 2>&1
fi

# kill the tail
kill %tail >/dev/null 2>&1

# reset the migrations in the box
vagrant ssh -c "cd /var/www; if [ -f \"artisan\" ]; then php artisan migrate; fi;"

# check for errors
# http://stackoverflow.com/a/2295565
errorKeys=("PHPUnit_Framework_Exception" "FATAL ERROR. TESTS NOT FINISHED" "FAILURES!" "ERRORS!" "TESTS EXECUTION TERMINATED")
errorPattern=$(echo ${errorKeys[@]}|tr " " "|")

if grep -Eow "$errorPattern" ${log}
    then
        message="TESTS FAILED. See ${log} for output.";
        if ${showNotify}; then
           echo ${message} | terminal-notifier -open "file://${PWD}/${log}" -sound "Glass"
        fi;
        echo ${message}
        exit 1;
    fi

#http://stackoverflow.com/a/13425821 time format
took=${SECONDS}
((sec=took%60, took/=60, min=took%60, hrs=took/60))
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)
message="Tests complete, took ${timestamp} to complete"

if ${showNotify}; then
        echo ${message} | terminal-notifier -open "file://${PWD}/tests/_output/coverage/index.html" -sound "Glass"
fi;

echo ${message}