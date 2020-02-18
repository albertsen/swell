const express = require("express")
const cors = require("cors")
const HttpStatus = require('http-status-codes');
const bodyParser = require("body-parser");
const asyncHandler = require('express-async-handler')

const workflowDefRepo = require("./repos/WorkflowDefRepo");
const jsonValidationService = require("./services/JSONValidationService");
const log = require("./log");
const errorHandler = require("./errorHandler");
const rest = require("./rest");


const app = express();
app.use(bodyParser.json())
app.use(cors());

function validateJSONRequest(schemaName) {
    return function(req, res, next) {
       let json = req.body;
       let result = jsonValidationService.validate(json, schemaName)
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



app.use(errorHandler);

app.listen(3000, () => log.info("Server listening on port 3000!"));