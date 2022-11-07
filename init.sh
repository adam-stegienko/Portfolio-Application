 #!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

# Import .env values
echo "\n${bold}--------------------------------------- IMPORTING ENV FILE ---------------------------------------${normal}\n"
if [ -f .env ]
    then
        export $(grep -v '^#' .env | xargs)
        echo "Values from .env file sourced successfully."
    else
        echo "No .env file provided."
        exit 1
fi

# Build the image
echo "\n${bold}---------------------------------------- BUILDING APP IMAGE --------------------------------------${normal}\n"
 docker build -t digital_planner:${APP_VERSION} .

# Reinstate docker compose topology
echo "\n${bold}---------------------------------------- RECREATING SET-UP ---------------------------------------${normal}\n"
 docker compose down
 docker compose up --detach --remove-orphans
 sleep 3
 docker logs digital_planner

 # Perform unit tests
 echo "\n${bold}--------------------------------------- RUNNING UNIT TESTS --------------------------------------${normal}\n"
 command ./unit_tests.sh