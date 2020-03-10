BUILD_DIR=build
PKGPATH=github.com/albertsen/swell

GO=go
GOBUILD=$(GO) build
GOTEST=$(GO) test
GOCLEAN=$(GO) clean
GOTEST=$(GO) test -v -count=1
GOGET=$(GO) get

KUBECTL=kubectl

DOCKER=docker
DOCKER_COMPOSE=docker-compose
DOCKER_DIR=./infra/docker

DB_NAME=swell
MONGO=mongo $(DB_NAME)


build: workflowdefservice workflowservice actiondispatcher

workflowdefservice:
	$(GOBUILD) -o $(BUILD_DIR)/workflowdefservice -v $(PKGPATH)/cmd/services/workflowdefservice
workflowservice:
	$(GOBUILD) -o $(BUILD_DIR)/workflowservice -v $(PKGPATH)/cmd/services/workflowservice
actiondispatcher:
	$(GOBUILD) -o $(BUILD_DIR)/actiondispatcher -v $(PKGPATH)/cmd/workers/actiondispatcher

cleandb:
	$(MONGO) --quiet --eval "db.workflowDefs.deleteMany({})" 
	$(MONGO) --quiet --eval "db.workflows.deleteMany({})" 

cleanqueues:
	rabbitmqadmin -f tsv -q list queues name | xargs -I qn rabbitmqadmin delete queue name=qn
	rabbitmqadmin -f tsv -q list bindings name | xargs -I qn rabbitmqadmin delete binding name=qn
	rabbitmqadmin -f tsv -q list exchanges name | grep -v amq | xargs -I qn rabbitmqadmin delete exchange name=qn

cleandata: cleandb cleanqueues

test: cleandata dockerrestart test-workflowdefservice test-workflowservice

test-workflowdefservice: cleandb
	mocha test/scenarios/workflowdef-api-test.js

test-workflowservice: cleandb
	curl --header "Content-Type: application/json" -d @./test/data/workflowdef.json http://localhost:8080/workflowdefs
	$(GOTEST) $(PKGPATH)/cmd/services/workflowservice

clean: 
	rm -rf $(BUILD_DIR)
	$(GOCLEAN)
	
# Cross compilation
build-linux: export CGO_ENABLED=0
build-linux: export GOOS=linux
build-linux: export GOARCH=amd64
build-linux: export BUILD_DIR=build/linux
build-linux: build

docker: build-linux
	$(DOCKER) build -t gcr.io/sap-se-commerce-arch/workflowdefservice:latest -f infra/docker/services/workflowdefservice/Dockerfile .
	$(DOCKER) build -t gcr.io/sap-se-commerce-arch/workflowservice:latest -f infra/docker/services/workflowservice/Dockerfile .
	$(DOCKER) build -t gcr.io/sap-se-commerce-arch/actiondispatcher:latest -f infra/docker/workers/actiondispatcher/Dockerfile .

dockerup: docker
	cd $(DOCKER_DIR) && $(DOCKER_COMPOSE) up --remove-orphans

dockerdown:
	cd $(DOCKER_DIR) && $(DOCKER_COMPOSE) down

dockerrestart: docker
	cd $(DOCKER_DIR) && \
		$(DOCKER_COMPOSE) stop workflowdefservice && \
		$(DOCKER_COMPOSE) stop workflowservice && \
		$(DOCKER_COMPOSE) stop actiondispatcher && \
		$(DOCKER_COMPOSE) up --no-deps -d workflowdefservice && \
		$(DOCKER_COMPOSE) up --no-deps -d workflowservice && \
		$(DOCKER_COMPOSE) up --no-deps -d actiondispatcher

setup:
	go get -u go.mongodb.org/mongo-driver/mongo \
		github.com/labstack/echo/... \
		github.com/streadway/amqp \
		github.com/google/uuid \
		github.com/stretchr/testify
	cd test && npm install