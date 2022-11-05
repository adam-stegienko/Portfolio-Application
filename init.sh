 #!/bin/bash

 docker build -t digital_planner:1.0 .
 docker compose down
 docker compose up --detach --remove-orphans
 sleep 3
 docker logs digital_planner