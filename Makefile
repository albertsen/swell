DBNMAME=swell

run:
	node app/server.js

cleardb:
	mongo $(DBNMAME) --eval "db.workflowDefs.drop()"


test: cleardb
	mocha tests/*.js
