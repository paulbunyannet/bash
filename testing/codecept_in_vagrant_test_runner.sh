#!/usr/bin/env bash
# restart the clock
SECONDS=0
#log file for output of tests
log="codecept-result.log"

finished=false
touch ${log}
echo -n "" >${log}

# check if terminal-notifier is installed for notifications
showNotify=1
command -v terminal-notifier >/dev/null 2>&1 || { showNotify=0; echo echo "Terminal-notifier is not installed, no notifications will display. Head to https://github.com/julienXX/terminal-notifier for more info.";}

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



# reset the migrations in the box
vagrant ssh -c "cd /var/www; if [ -f \"artisan\" ]; then php artisan migrate; fi;"

# check for errors
# http://stackoverflow.com/a/2295565
errorKeys=("PHPUnit_Framework_Exception" "FATAL ERROR. TESTS NOT FINISHED" "FAILURES!" "ERRORS!" "TESTS EXECUTION TERMINATED")
errorMessage="TESTS FAILED. See ${log} for output.";

while read -r line
do
    for i in ${errorKeys[@]}
    do
        case "$line" in *"$i"*)
           if ${showNotify}; then
                echo ${errorMessage} | terminal-notifier -open "file://${PWD}/${log}" -sound "Glass"
           fi;
            echo ${errorMessage}
            # kill the tail
            kill %tail >/dev/null 2>&1
            exit 1;
        esac
    done
done <${log}

#http://stackoverflow.com/a/13425821 time format
took=${SECONDS}
((sec=took%60, took/=60, min=took%60, hrs=took/60))
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)
message="Tests complete, took ${timestamp} to complete"

if ${showNotify}; then
        echo ${message} | terminal-notifier -open "file://${PWD}/tests/_output/coverage/index.html" -sound "Glass"
fi;

echo ${message}
# kill the tail
kill %tail >/dev/null 2>&1