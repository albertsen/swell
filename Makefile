PSQL_HOST=localhost
PSQL_PORT=5432
PSQL=psql -h localhost -p $(PSQL_PORT)
DB_NAME=swell
DB_USER=swelladmin
DB_SUPERUSER=postgres
RABBITMQCTL=rabbitmqctl

build:
	mix compile

test:
	mix test

createdb:
	$(PSQL) postgres -f sql/create_db.sql 

creatdbusers:
	$(PSQL) $(DB_NAME) -f sql/create_users.sql

dropdbtables:
	$(PSQL) $(DB_NAME) -c "DROP TABLE workflows"

createdbtables:
	$(PSQL) -U $(DB_USER) $(DB_NAME) -f sql/create_tables.sql

dropdb:
	$(PSQL) postgres -c "DROP DATABASE swell"

purgedb:
	$(PSQL) $(DB_NAME) -c "DELETE FROM workflows"

purgequeues:
	$(RABBITMQCTL) purge_queue errors
	$(RABBITMQCTL) purge_queue done
	$(RABBITMQCTL) purge_queue steps
	$(RABBITMQCTL) purge_queue transitions
	$(RABBITMQCTL) purge_queue persistence

purgedata: purgedb purgequeues

test: purgedata test