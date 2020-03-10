const express = require("express")
const cors = require("cors")
const HttpStatus = require('http-status-codes');
const bodyParser = require("body-parser");
const asyncHandler = require('express-async-handler')

const workflowDefRepo = require("lib/repos/WorkflowDefRepo");
const workflowRepo = require("lib/repos/WorkflowRepo");
const jsonValidator = require("lib/JSONValidator");
const log = require("lib/log");
const errorHandler = require("lib/errorHandler");
const rest = require("lib/rest");
const messaging = require("lib/Messaging");
const db = require("lib/DB");


const app = express();
app.use(bodyParser.json())
app.use(cors());

function validateJSONRequest(schemaName) {
    return function (req, res, next) {
        let json = req.body;
        let result = jsonValidator.validate(json, schemaName)
        if (result.valid) next()
        else next(result.error);
    }
}

app.post("/workflowdefs",
    validateJSONRequest("WorkflowDef"),
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
    validateJSONRequest("WorkflowDef"),
    asyncHandler(async (req, res) => {
        let id = req.params["id"];
        let result = await workflowDefRepo.update(id, req.body)
        rest.sendStatus(res, HttpStatus.OK, result, result);
    })
);

app.delete("/workflowdefs/:id",
    asyncHandler(async (req, res) => {
        let id = req.params["id"];
        await workflowDefRepo.delete(id, req.body)
        rest.sendStatus(res, HttpStatus.OK);
    })
);

app.post("/workflows",
    validateJSONRequest("Workflow"),
    asyncHandler(async (req, res) => {
        let result = await workflowRepo.create(req.body)
        messaging.publish("actions", result)
        rest.sendStatus(res, HttpStatus.CREATED, result);
    })
);

app.get("/workflows/:id",
    asyncHandler(async (req, res) => {
        let id = req.params["id"];
        let doc = await workflowRepo.findById(id)
        rest.sendStatus(res, HttpStatus.OK, doc);
    })
);


app.use(errorHandler);

async function init() {
    await db.connect();
    await messaging.connect();
}

init()
    .then(() => {
        app.listen(3000, () => log.info("Workflow service listening on port 3000!"));
    })
    .catch((error) => {
        log.error("Cannot start server");
        log.error(error);
        process.exit(1);
    });