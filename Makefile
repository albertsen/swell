DBNMAME=swell
DIR=$(shell pwd)
APP_DIR=$(DIR)/app
export NODE_PATH=$(APP_DIR)

runworkflowservice:
	node app/services/workflowService.js

runactiondispatcher:
	node app/workers/actions/actionDispatcher.js

cleardb:
	mongo $(DBNMAME) --eval "db.workflowDefs.drop()"

clearqueue:
	rabbitmqadmin -f tsv -q list queues name | xargs -I qn rabbitmqadmin delete queue name=qn
	rabbitmqadmin -f tsv -q list exchanges name | grep -v amq | xargs -I qn rabbitmqadmin delete exchange name=qn

clear: cleardb purgequeues

test: cleardb
	mocha tests/*.js