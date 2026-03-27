FROM mcr.microsoft.com/mssql/server:2022-latest
USER root
COPY script.sql /script.sql
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]