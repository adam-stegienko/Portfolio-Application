 #!/bin/bash

# Import .env values
if [ -f .env ]
    then
        export $(grep -v '^#' .env | xargs);
    else
        echo "No .env file provided."
        exit 1
fi

# Build the image
 docker build -t digital_planner:${APP_VERSION} .

# Reinstate docker compose topology
 docker compose down
 docker compose up --detach --remove-orphans
 sleep 3
 docker logs digital_planner