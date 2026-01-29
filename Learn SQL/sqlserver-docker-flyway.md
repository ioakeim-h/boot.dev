# SQL Server + Docker + Flyway: A Practical Workflow

This project provides a fully containerized development environment for SQL Server using Docker, integrated with Flyway for database migrations. Created as a support document for my [SQL Guide](Learn%20SQL.md).

## Setup

The [project](sql-docker-flyway/) is organized around Docker Compose, with a `compose.yaml` file orchestrating two containers: one for SQL Server and one for Flyway. We have a `.env` file to store environment variables such as passwords and database names, and a `flyway.conf` file to configure Flyway’s connection and migration settings. The `db/migrations` directory holds all versioned SQL scripts, starting with creating a `CustomersDB`, then creating tables, renaming columns, and even reverting changes. The `sqlserver` directory contains subdirectories for storing database data, logs, and secrets, ensuring the SQL Server instance retains its state.

```conf
project/
├─ compose.yaml
├─ Dockerfile
├─ .env                                     
├─ flyway.conf        
├─ db/
│  └─ migrations/                           
│      ├─ V1__create_CustomersDB.sql 
│      ├─ V2__create_customers_table.sql
|      ├─ V3__rename_FirstName_column.sql
|      └─ V4__revert_FirstName_column_rename.sql   
└─ sqlserver/
   ├─ data/         
   ├─ log/          
   └─ secrets/      
```

## Compose file

The [`compose.yaml`](sql-docker-flyway/compose.yaml) file outlines how the two containers interact with each other. When Docker Compose starts, it first creates the a network. The SQL Server container starts, initializing the database and reporting its health using the defined health check. Once SQL Server is healthy, the Flyway container starts, reads the migration scripts, applies them in order, and exits. The SQL Server container continues running, retaining all data, logs, and secrets.

### Networks

```yaml
networks:
  appnet:
    driver: bridge
```
- Defines a custom network called `appnet` using the bridge driver. Both containers will use this network to communicate with each other by name, rather than relying on external IPs.

### SQL Server Service

```yaml
services:
  sqlserver:
    build: .
    container_name: sqlserver
    networks:
      - appnet
    ports:
      - "1433:1433"
    volumes:
      - ./sqlserver/data:/var/opt/mssql/data
      - ./sqlserver/log:/var/opt/mssql/log
      - ./sqlserver/secrets:/var/opt/mssql/secrets
    healthcheck:
      test: ["CMD", "/opt/mssql-tools/bin/sqlcmd", "-S", "localhost", "-U", "sa", "-P", "${MSSQL_SA_PASSWORD}", "-Q", "SELECT 1"]
      interval: 10s
      retries: 5
      start_period: 10s
```
- The `sqlserver` service is built from the [`Dockerfile`](sql-docker-flyway/Dockerfile) in the current directory and given a fixed container name for easier reference. It is attached to the `appnet` network so other containers, like Flyway, can reach it directly. Port `1433` is exposed to allow host access to SQL Server. Local directories are mapped into the container for data, logs, and secrets, ensuring that the database state persists outside the container. A health check runs a simple `SELECT 1` query every 10 seconds via `sqlcmd`, retrying up to five times after a start period of 10 seconds, to confirm that SQL Server is ready before dependent services start.

### Flyway Service

```yaml
  flyway:
    image: flyway/flyway:11
    container_name: flyway
    networks:
      - appnet
    depends_on:
      sqlserver:
        condition: service_healthy
    volumes:
      - ./db/migrations:/flyway/sql
      - ./flyway.conf:/flyway/conf/flyway.conf
    command: migrate
```
- The `flyway` service uses the official Flyway Docker image and is also attached to the `appnet` network, allowing it to connect to SQL Server using the container name. The `depends_on` configuration ensures Flyway starts only after SQL Server passes its health check. The [migration scripts](sql-docker-flyway/db/migrations/) and [Flyway configuration file](sql-docker-flyway/flyway.conf) are mapped into the container via volumes. The `command: migrate` line instructs Flyway to automatically apply all pending migrations when the container starts and then exit.

## Dockerfile

```Dockerfile
FROM mcr.microsoft.com/mssql/server:2025-latest

USER root

# Install sqlcmd 
RUN apt-get update \
    && apt-get install -y curl apt-transport-https gnupg \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list \
       > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/profile.d/mssql.sh

USER mssql
```
- The [`Dockerfile`](sql-docker-flyway/Dockerfile) extends the official SQL Server 2025 image and installs the `sqlcmd` command-line tool along with its dependencies. It temporarily switches to the `root` user to install packages and configure the system `PATH`, then switches back to the default `mssql` user for security. With this setup, you can run SQL Server in a container and use `sqlcmd` to interact with the database, execute queries, or run scripts directly from the container shell.

## .env

```conf
ACCEPT_EULA=Y
MSSQL_SA_PASSWORD=Str0ngPa55!
```
- Docker Compose automatically loads the [`.env`](sql-docker-flyway/.env) file for variable substitution (`${VAR}`) in the `compose.yaml`, allowing us to parameterize values such as passwords without hardcoding them. This substitution happens before the containers start, during the parsing of the Compose file, and is used only by Docker Compose itself to configure the services. This is different from the [`environment`](https://docs.docker.com/reference/compose-file/services/#environment) command, which explicitly sets environment variables inside the container at runtime, making them available to the processes running within. 

**WARNING:** Any configuration file that contains real passwords, API keys, or other sensitive information — such as a `.env` file with `MSSQL_SA_PASSWORD` — as well as any secrets directories or files used by containers to store credentials, should never be pushed to a public repository. In this project, they are included only for demonstration purposes.

## flyway.conf 

```conf
flyway.url=jdbc:sqlserver://sqlserver:1433;databaseName=master;trustServerCertificate=true
flyway.user=sa
flyway.password=Str0ngPa55!
flyway.locations=filesystem:/flyway/sql
```
- The [`flyway.conf`](sql-docker-flyway/flyway.conf) file automatically configures Flyway, specifying the database connection, user credentials, and the location of migration scripts. Flyway initially connects to the system `master` database which always exists in sql server. This is useful for creating the application database (occurs via [our first migration](sql-docker-flyway/db/migrations/V1__create_CustomersDB.sql)) if it doesn’t exist yet. The `trustServerCertificate=true` option allows Flyway to accept the server’s certificate without verification, which is convenient for development environments using self-signed certificates.

