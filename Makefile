DBNMAME=swell
DIR=$(shell pwd)
APP_DIR=$(DIR)/app

DOCKER=docker
DOCKER_COMPOSE=docker-compose
DOCKER_DIR=$(DIR)/infra/docker

export NODE_PATH=$(APP_DIR)

runworkflowservice:
	node app/services/workflowService.js

runactiondispatcher:
	node app/workers/actions/actionDispatcher.js

cleandb:
	mongo $(DBNMAME) --eval "db.workflowDefs.drop()"
	mongo $(DBNMAME) --eval "db.workflows.drop()"

cleanqueue:
	rabbitmqadmin -f tsv -q list queues name | xargs -I qn rabbitmqadmin delete queue name=qn
	rabbitmqadmin -f tsv -q list exchanges name | grep -v amq | xargs -I qn rabbitmqadmin delete exchange name=qn

clean: cleandb purgequeues

test: cleandb
	mocha tests/*.js

docker:
	$(DOCKER) build -t swell-base:latest -f $(DOCKER_DIR)/base/Dockerfile .
	$(DOCKER) build -t swell-workflowservice:latest -f $(DOCKER_DIR)/services/workflowservice/Dockerfile .
	$(DOCKER) build -t swell-actiondispatcher:latest -f $(DOCKER_DIR)/workers/actiondispatcher/Dockerfile .

dockerstart:
	cd $(DOCKER_DIR) && $(DOCKER_COMPOSE) up --remove-orphans

dockerstop:
	cd $(DOCKER_DIR) && $(DOCKER_COMPOSE) down

dockerrestart: docker
	cd $(DOCKER_DIR) && \
		$(DOCKER_COMPOSE) stop workflowservice && \
		$(DOCKER_COMPOSE) up --no-deps -d workflowservice
