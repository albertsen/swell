const chakram = require('chakram');
const workflowDef = require('./data/WorkflowDef.json');
const workflow = require('./data/Workflow.json');
const url = require("./config").workflowService.url

expect = chakram.expect;


describe("Workflow def and workflow CRUD", function () {
    it("should do CRUD successfully", () => {
        return chakram.post(url + "/workflowdefs", workflowDef)
            .then((response) => {
                expect(response).to.have.status(201);
                expect(response).to.comprise.of.json(workflowDef);
                return chakram.get(url + "/workflowdefs/" + workflowDef.id);
            })
            .then((response) => {
                expect(response).to.have.status(200);
                expect(response).to.comprise.of.json(workflowDef);
                return chakram.post(url + "/workflows", workflow);
            })
            .then((response) => {
                expect(response).to.have.status(201);
                workflow.id = response.body.id;
                expect(response).to.comprise.of.json(workflow);
                return chakram.get(url + "/workflows/" + workflow.id);
            })
            .then((response) => {
                expect(response).to.have.status(200);
                expect(response).to.comprise.of.json(workflow);
                workflowDef.description = "Updated description";
                return chakram.put(url + "/workflowdefs/" + workflowDef.id, workflowDef);
            })
            .then((response) => {
                expect(response).to.have.status(200);
                expect(response).to.comprise.of.json(workflowDef);
                return chakram.get(url + "/workflowdefs/" + workflowDef.id);
            })
            .then((response) => {
                expect(response).to.have.status(200);
                expect(response).to.comprise.of.json(workflowDef);
                return chakram.delete(url + "/workflowdefs/" + workflowDef.id);
            })
            .then((response) => {
                expect(response).to.have.status(200);
                return chakram.get(url + "/workflowdefs/doesnotexist");
            })
            .then((response) => {
                expect(response).to.have.status(404);
            })
    });
});


describe("Workflow def error messages", function () {
    it("should return a schema validation error", () => {
        let response = chakram.post(url + "/workflowdefs", { "areYouInvalid": true });
        expect(response).to.have.status(422);
        expect(response).to.comprise.of.json({
            "errorCode": "JSON_VALIDATION_ERROR",
            "message": "Invalid JSON document",
            "details": [
                {
                    "keyword": "required",
                    "dataPath": "",
                    "schemaPath": "#/required",
                    "params": {
                        "missingProperty": "id"
                    },
                    "message": "should have required property 'id'"
                }
            ]
        });
        return chakram.wait();
    });
    it("should return a 'not found' error", () => {
        let response = chakram.get(url + "/workflowdefs/doesnotexist");
        expect(response).to.have.status(404);
        return chakram.wait();
    });
});

describe("Workflow error messages", function () {
    it("should return a schema validation error", () => {
        let response = chakram.post(url + "/workflows", { "areYouInvalid": true });
        expect(response).to.have.status(422);
        expect(response).to.comprise.of.json({
            "errorCode": "JSON_VALIDATION_ERROR",
            "message": "Invalid JSON document",
            "details": [
                {
                    "keyword": "required",
                    "dataPath": "",
                    "schemaPath": "#/required",
                    "params": {
                        "missingProperty": ".workflowDefId"
                    },
                    "message": "should have required property '.workflowDefId'"
                }
            ]
        });
        return chakram.wait();
    });
    it("should return a 'not found' error", () => {
        let response = chakram.get(url + "/workflows/doesnotexist");
        expect(response).to.have.status(404);
        return chakram.wait();
    });
});
