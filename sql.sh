# Create directories for data, log, and secrets if they don't exist
mkdir -p ./data
mkdir -p ./log
mkdir -p ./secrets

# Run the MS SQL Server container
docker run --name sql-server-dev \
    -e 'ACCEPT_EULA=Y' \
    -e 'MSSQL_SA_PASSWORD=Passw0rd!' \
    -p 1433:1433 \
    -v "$(pwd)/data:/var/opt/mssql/data" \
    -v "$(pwd)/log:/var/opt/mssql/log" \
    -v "$(pwd)/secrets:/var/opt/mssql/secrets" \
    -d mcr.microsoft.com/mssql/server:2022-latest