#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)
green='\033[0;32m'
no_color='\033[0m'

echo "${bold}TEST 2/5 - POST Sign up${normal}"
curl -i -d "username=unit_test" -d "password=unit_test" -X POST http://localhost/sign-up | tac | tac | head -6

if [[ $(curl -i -d "username=unit_test" -d "password=unit_test" -X POST http://localhost/sign-up | tac | tac | head -1 | cut -d " " -f2) == "200" ]]; then
    echo "Passed."
    echo "Passed." >> output.txt
else
    echo "Failed."
    echo "Failed." >> output.txt
fi