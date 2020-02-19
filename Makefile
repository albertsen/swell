DBNMAME=swell

runworkflowservice:
	node app/services/workflowService.js

cleardb:
	mongo $(DBNMAME) --eval "db.workflowDefs.drop()"

clearqueue:
	rabbitmqadmin -f tsv -q list queues name | xargs -I qn rabbitmqadmin delete queue name=qn
	rabbitmqadmin -f tsv -q list exchanges name | grep -v amq | xargs -I qn rabbitmqadmin delete exchange name=qn

clear: cleardb purgequeues

test: cleardb
	mocha tests/*.js
