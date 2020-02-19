const express = require("express")
const cors = require("cors")
const HttpStatus = require('http-status-codes');
const bodyParser = require("body-parser");
const asyncHandler = require('express-async-handler')

const workflowDefRepo = require("lib/repos/WorkflowDefRepo");
const jsonValidator = require("lib/JSONValidator");
const log = require("lib/log");
const errorHandler = require("lib/errorHandler");
const rest = require("lib/rest");
const queue = require("lib/Queue");


const app = express();
app.use(bodyParser.json())
app.use(cors());

function validateJSONRequest(schemaName) {
    return function(req, res, next) {
       let json = req.body;
       let result = jsonValidator.validate(json, schemaName)
       if (result.valid) next()
       else next(result.error);
    }
}

app.post("/workflowdefs",
    validateJSONRequest("workflow_def"),
    asyncHandler(async (req, res) => {
        let result = await workflowDefRepo.create(req.body)
        rest.sendStatus(res, HttpStatus.CREATED, result);
    })
);


app.get("/workflowdefs/:id",
    asyncHandler(async (req, res) => {
        let id = req.params["id"];
        let doc = await workflowDefRepo.findById(id)
        rest.sendStatus(res, HttpStatus.OK, doc);
    })
);

app.put("/workflowdefs/:id",
    validateJSONRequest("workflow_def"),
    asyncHandler(async (req, res) => {
        let id = req.params["id"];
        let result = await workflowDefRepo.update(id, req.body)
        rest.sendStatus(res, HttpStatus.OK, result);
    })
);

app.delete("/workflowdefs/:id",
    asyncHandler(async (req, res) => {
        let id = req.params["id"];
        let result = await workflowDefRepo.delete(id, req.body)
        rest.sendStatus(res, HttpStatus.OK, result);
    })
);

app.post("/workflows",
    asyncHandler(async (req, res) => {
        queue.publish("actions", "", req.body)
        rest.sendStatus(res, HttpStatus.CREATED);
    })
);



app.use(errorHandler);

app.listen(3000, () => log.info("Server listening on port 3000!"));