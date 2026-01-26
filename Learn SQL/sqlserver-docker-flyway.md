# SQL Server + Docker + Flyway: A Practical Workflow

Covers the end-to-end process of managing a SQL Server database in a containerized environment with migrations. This is a support document for my [SQL Guide](/Learn%20SQL.md) (check it out).

- Create a network for SQL Server and Flyway to communicate
- Baseline database schema for Flyway
- "Schema [dbo] is up to date. No migration necessary." the power of Flyway


Manage your project's structure carefully:
- [Database volumes](./Learn SQL/#volumes-required) (data, logs, secrets) in their own directory
- Migrations in their own directory



Docker compose



docker pull mcr.microsoft.com/mssql/server:<tag>
docker pull flyway/flyway:<tag>

docker run -d \
  --name <container_name> \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD='<password>' \
  -p <host_port>:1433 \
  -v <host_sqlserver_volume_path>/data:/var/opt/mssql/data \
  -v <host_sqlserver_volume_path>/log:/var/opt/mssql/log \
  -v <host_sqlserver_volume_path>/secrets:/var/opt/mssql/secrets \
  mcr.microsoft.com/mssql/server:<tag>




docker run --rm \
  -v /home/ihadjimpalasis/DockerSQL/MigrationsVolume:/flyway/sql \
  -v /home/ihadjimpalasis/DockerSQL/SqlVolume/flyway.conf:/flyway/conf/flyway.conf \
  flyway/flyway migrate

