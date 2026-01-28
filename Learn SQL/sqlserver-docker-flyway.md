# SQL Server + Docker + Flyway: A Practical Workflow

Covers the end-to-end process of managing a SQL Server database in a containerized environment with migrations. This is a support document for my [SQL Guide](/Learn%20SQL.md) (check it out).

project/
├─ compose.yaml
├─ .env
├─ flyway.conf        
├─ db/
│  └─ migrations/
│      ├─ V1__create_table.sql
│      └─ V2__insert_data.sql
├─ sqlserver/
│  ├─ data/
│  ├─ log/
│  └─ secrets/




- Create a network for SQL Server and Flyway to communicate
- Baseline database schema for Flyway
- "Schema [dbo] is up to date. No migration necessary." the power of Flyway


Manage your project's structure carefully:
- [Database volumes](./Learn SQL/#volumes-required) (data, logs, secrets) in their own directory
- Migrations in their own directory



Docker compose



Steps:

docker-compose build sqlserver

need to build first because our SQL Server service is using a custom Dockerfile

docker compose up