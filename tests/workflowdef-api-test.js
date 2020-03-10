const chakram = require('chakram');
const workflowDef = require('./data/WorkflowDef.json');
const url = require("./config").workflowService.url

expect = chakram.expect;


describe("Workflow def API", function () {
    it("should create workflow def", () => {
        let response = chakram.post(url + "/workflowdefs", workflowDef);
        expect(response).to.have.status(201);
        expect(response).to.comprise.of.json(workflowDef);
        return chakram.wait();
    });
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
    it("should return a valid workflow def", () => {
        let response = chakram.get(url + "/workflowdefs/" + workflowDef.id);
        expect(response).to.have.status(200);
        expect(response).to.comprise.of.json(workflowDef);
        return chakram.wait();
    });
    it("should return a 'not found' error", () => {
        let response = chakram.get(url + "/workflowdefs/doesnotexist");
        expect(response).to.have.status(404);
        return chakram.wait();
    });
    workflowDef.description = "Updated description";
    it("should update a workflow def", () => {
        let response = chakram.put(url + "/workflowdefs/" + workflowDef.id, workflowDef);
        expect(response).to.have.status(200);
        expect(response).to.comprise.of.json(workflowDef);
        return chakram.wait();
    });
    it("should return an updated workflow def", () => {
        let response = chakram.get(url + "/workflowdefs/" + workflowDef.id);
        expect(response).to.have.status(200);
        expect(response).to.comprise.of.json(workflowDef);
        return chakram.wait();
    });
    it("should delete the workflow def", () => {
        let response = chakram.delete(url + "/workflowdefs/" + workflowDef.id);
        expect(response).to.have.status(200);
        return chakram.wait();
    });
    it("should return a 'not found' error after document was deleted", () => {
        let response = chakram.get(url + "/workflowdefs/doesnotexist");
        expect(response).to.have.status(404);
        return chakram.wait();
    });
});