#!bin/bash

/opt/mssql/bin/sqlservr | /opt/mssql/bin/permissions_check.sh | /init/initdb.sh