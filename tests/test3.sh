#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)
green='\033[0;32m'
no_color='\033[0m'

echo "${bold}TEST 3/5 - POST Sign in and GET Planner${normal}"
curl -i -d "username=unit_test" -d "password=unit_test" -X POST http://localhost/sign-in | tac | tac | head -6

if [[ $(curl -i -d "username=unit_test" -d "password=unit_test" -X POST http://localhost/sign-in | tac | tac | head -1 | cut -d " " -f2) == "302" && $(curl -i -d "username=unit_test" -d "password=unit_test" -X POST http://localhost/sign-in | grep -E "^Location\:\s\/planner") ]]; then
    echo "Passed."
    echo "Passed." >> output.txt
else
    echo "Failed."
    echo "Failed." >> output.txt
fi