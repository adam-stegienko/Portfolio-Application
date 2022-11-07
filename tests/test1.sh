#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)
green='\033[0;32m'
no_color='\033[0m'

echo "${bold}TEST 1/5 - GET Homepage${normal}"
curl -i http://localhost | tac | tac | head -8

if [[ $(curl -i http://localhost | tac | tac | head -1 | cut -d " " -f2) == "200" ]]; then
    echo "Passed."
    echo "Passed." >> output.txt
else
    echo "Failed."
    echo "Failed." >> output.txt
fi