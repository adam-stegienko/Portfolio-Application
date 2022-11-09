 #!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

# Import .env values
echo "\n${bold}--------------------------------------- IMPORTING ENV FILE ---------------------------------------${normal}\n"
 if [ -f .env ]
     then
         export $(grep -v '^#' .env | xargs)
         echo "Values from .env file sourced successfully. Start."
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

# Check start-up logs
echo "\n${bold}----------------------------------------- DATABASE LOGS ------------------------------------------${normal}\n"
 docker logs mssql_server
 sleep 2
echo "\n${bold}---------------------------------------- APPLICATION LOGS ----------------------------------------${normal}\n"
 docker logs digital_planner
 sleep 2
echo "\n${bold}--------------------------------------- REVERSE PROXY LOGS ---------------------------------------${normal}\n"
 docker logs reverse_nginx
 sleep 2

 # Perform unit tests
echo "\n${bold}--------------------------------------- RUNNING UNIT TESTS ---------------------------------------${normal}\n"
 command ./unit_tests.sh