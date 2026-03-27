#!/bin/bash

/opt/mssql/bin/sqlservr &

sleep 18s

/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Cfopanyaforger*" -i /script.sql -C

wait