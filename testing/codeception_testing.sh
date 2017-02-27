#!/usr/bin/env bash
NC='\033[0m' # No Color
TAB=' - '
COLS=$(tput cols)
#log file for output of tests
log="codecept-result.log"
finished=false
touch ${log}
echo -n "" >${log}
tail -f ${log} &

# run migrations if artisan command exists
if [ -f "artisan" ]
then
    php artisan config:clear;
    php artisan migrate;
fi
# -------------------------------------------------------------------------------------
# go though the ./tests folder and get all the yaml files.
# Then split the file name to get the suite name
rm -f ./tests/test-suites | true

# find all the test suite files
find ./tests -name '*.yml' -print | grep suite > ./tests/test-suites

# loop though the files in the ./tests/test-suites file
cat ./tests/test-suites | while read s; do

  suite=$(basename ${s})

  # explode file name by dot
  IFS='.' read -a suitePart <<< "${suite}"

  # append to final value
  suiteFinal="${suiteFinal} ${suitePart[0]}"

  # write out to the test-suites file
  echo ${suiteFinal} > ./tests/test-suites

done
# test suites
# read and explode the list by delimiter
#now the testSuites variable has a list of all the suites by name
IFS=' ' read -r -a testSuites <<< $(cat ./tests/test-suites)

# do codeception cleanup
wget -N -q http://codeception.com/codecept.phar
php codecept.phar clean;
php codecept.phar build;

errorKeys=("PHPUnit_Framework_Exception" "FATAL ERROR. TESTS NOT FINISHED" "FAILURES!" "ERRORS!" "TESTS EXECUTION TERMINATED")
errorMessage="TESTS FAILED! See ${log} for output."
failedReAttempt="TESTS FAILED. Will retry failed tests."

# loop though all the text suites, marking the time they started, ended and how long they took
for ((i=0; i<${#testSuites[@]}; i++))
do
    SECONDS=0;
    c=0
    # http://stackoverflow.com/questions/24367088/print-a-character-till-end-of-line
    echo -e "\033[49m$(for ((i=0; i<($COLS - 2); i++));do printf ${TAB}; done; echo)${NC}"
    echo -e "\033[30;48;5;200m${TAB}Now running ${testSuites[i]} test suite, started at $(date +'%Y-%m-%d %H:%M:%S')${TAB}${NC}"

    # run tests outside if the suite name contains "static", otherwise run them in the vagrant box
    if [[ "${whereToRun[i]}" == *"static"* ]]
        then
            # run tests in the suite
            php codecept.phar run ${testSuites[i]} -v > ${log} 2>&1
        else
            # run tests in the suite
            php codecept.phar run ${testSuites[i]} -v > ${log} 2>&1
    fi

    took=${SECONDS}
    ((sec=took%60, took/=60, min=took%60, hrs=took/60))
    timestamp=$(printf "%d hours, %02d minutes and %02d seconds" $hrs $min $sec)

    # check for failed tests and rerun them (Firefox might have lost
    # connection for instance in an acceptance test)
    if [ -f "tests/_output/failed" ]
        then
            echo -e "\033[49m$(for ((i=0; i<($COLS - 2); i++));do printf ${TAB}; done; echo)${NC}"
            echo -e "\033[30;48;5;200m${TAB}${failedReAttempt} Started at $(date +'%Y-%m-%d %H:%M:%S')${TAB}${NC}"
            if [[ "${whereToRun[i]}" == *"static"* ]]
            then
                # run tests in the suite
                php codecept.phar run -g failed > ${log} 2>&1
            else
                # run tests in the suite
                php codecept.phar run -g failed > ${log} 2>&1
            fi
    fi


    # check for errors
    # http://stackoverflow.com/a/2295565
    while read -r line
    do
        for e in ${errorKeys[@]}
        do
            case "$line" in *"$e"*)
                echo -e "\033[48;5;9m${TAB}${errorMessage}${TAB}${NC}"
                echo -e "\033[48;5;6m${TAB}Test suite ${testSuites[i]} ran, took ${timestamp} to complete${TAB}${NC} "
                printf "\n\n"
                # kill the tail
                kill %tail >/dev/null 2>&1
                exit 1;
            esac
        done
    done <${log}

    echo -e "\033[30;48;5;82m${TAB}Completed ${testSuites[i]} test suite, ended at $(date +'%Y-%m-%d %H:%M:%S')${TAB}${NC}"
    echo -e "\033[30;48;5;6m${TAB}Test suite ${testSuites[i]} complete, took ${timestamp} to complete${TAB}${NC}"
    printf "\n"
done



# kill the tail
kill %tail >/dev/null 2>&1
