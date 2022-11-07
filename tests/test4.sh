#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)
green='\033[0;32m'
no_color='\033[0m'

echo "${bold}TEST 4/5 - POST Sign out${normal}"
curl -i http://localhost/sign-out  | tac | tac | head -10

if [[ $(curl -i http://localhost/sign-out | grep -E "^Location\:\s\/") ]]; then
    echo "Passed."
    echo "Passed." >> output.txt
else
    echo "Failed."
    echo "Failed." >> output.txt
fi