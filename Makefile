PSQL_HOST=localhost
PSQL_PORT=5432
PSQL=psql -h localhost -p $(PSQL_PORT)
DB_NAME=swell
DB_USER=swelladmin
DB_SUPERUSER=postgres
RABBITMQCTL=rabbitmqctl

build:
	mix compile

test: purgedata
	mix test

purgedb:
	mongo swell --quiet --eval "db.workflowDefs.deleteMany({})" 
	mongo swell --quiet --eval "db.workflows.deleteMany({})" 

purgequeues:
	rabbitmqadmin -f tsv -q list queues name | xargs -I qn rabbitmqadmin delete queue name=qn
	rabbitmqadmin -f tsv -q list bindings name | xargs -I qn rabbitmqadmin delete binding name=qn
	rabbitmqadmin -f tsv -q list exchanges name | grep -v amq | xargs -I qn rabbitmqadmin delete exchange name=qn

purgedata: purgedb purgequeues