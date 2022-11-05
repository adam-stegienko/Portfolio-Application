#!bin/bash

echo "Creating MS SQL Login."

for i in {1..50};
do

/opt/mssql-tools/bin/sqlcmd -U $MSSQL_SA_USER -P $MSSQL_SA_PASSWORD -S localhost -i /init/initdb.sql

    if [ $? -eq 0 ]
    then
        echo "MS SQL Login created."
        break
    else
        echo "..."
        sleep 1
    fi

done