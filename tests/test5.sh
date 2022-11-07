#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)
green='\033[0;32m'
no_color='\033[0m'

echo "${bold}TEST 5/5 - GET Planner unauthenticated${normal}"
curl -i http://localhost/planner | tac | tac | head -11

if [[ $(curl -i http://localhost/planner | grep -v -E "^Location\:\s\/planner") ]]; then
    echo "Passed."
    echo "Passed." >> output.txt
else
    echo "Failed."
    echo "Failed." >> output.txt
fi