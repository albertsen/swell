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
const db = require("lib/db");


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
        rest.sendBody(res, HttpStatus.CREATED, result);
    })
);


app.get("/workflowdefs/:id",
    asyncHandler(async (req, res) => {
        let id = req.params["id"];
        let doc = await workflowDefRepo.findOneById(id)
        if (doc) {
            rest.sendBody(res, HttpStatus.OK, doc);
        }
        else {
            rest.sendMessage(res, HttpStatus.NOT_FOUND,
                "No workflow definition found with ID: " + id);
        }

    })
);

app.put("/workflowdefs/:id",
    validateJSONRequest("WorkflowDef"),
    asyncHandler(async (req, res) => {
        let id = req.params["id"];
        let result = await workflowDefRepo.update(id, req.body)
        rest.sendBody(res, HttpStatus.OK, result, result);
    })
);

app.delete("/workflowdefs/:id",
    asyncHandler(async (req, res) => {
        let id = req.params["id"];
        await workflowDefRepo.delete(id, req.body)
        rest.sendBody(res, HttpStatus.OK);
    })
);

app.post("/workflows",
    validateJSONRequest("Workflow"),
    asyncHandler(async (req, res) => {
        let workflow = req.body
        let workflowDef = await workflowDefRepo.findOneById(workflow.workflowDefId)
        if (!workflowDef) {
            rest.sendMessage(res, HttpStatus.UNPROCESSABLE_ENTITY,
                "Cannot find workflow definition with ID: " + workflow.workflowDefId);
            return
        }
        let result = await workflowRepo.create(workflow)
        messaging.publish("actions", result)
        rest.sendBody(res, HttpStatus.CREATED, result);
    })
);

app.get("/workflows/:id",
    asyncHandler(async (req, res) => {
        let id = req.params["id"];
        let doc = await workflowRepo.findOneById(id);
        if (!doc) {
            rest.sendMessage(res, HttpStatus.NOT_FOUND,
                "Cannot find workflow with ID: " + id);
            return
        }
        rest.sendBody(res, HttpStatus.OK, doc);
    })
);


app.use(errorHandler);

async function init() {
    await db.connect();
    await messaging.connect();
}

init()
    .then(() => {
        let port = process.env.PORT || 3000
        app.listen(port, () => log.info("Workflow service listening on port " + port));
    })
    .catch((error) => {
        log.error("Cannot start server");
        log.error(error);
        process.exit(1);
    });