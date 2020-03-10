const chakram = require('chakram');
const workflowDef = require('../data/workflowdef.json');
const url = "http://localhost:8080/workflowdefs"

expect = chakram.expect;


describe("Workflow def API", function () {
    it("should create workflow def", () => {
        let response = chakram.post(url, workflowDef);
        expect(response).to.have.status(201);
        expect(response).to.comprise.of.json(workflowDef);
        return chakram.wait();
    });
    it("should return a 'conflict' error when trying to create workflow def again", () => {
        let response = chakram.post(url, workflowDef);
        expect(response).to.have.status(422);
        expect(response).to.comprise.of.json(workflowDef);
        return chakram.wait();
    });
    it("should return a valid workflow def", () => {
        let response = chakram.get(url + "/" + workflowDef.id);
        expect(response).to.have.status(200);
        expect(response).to.comprise.of.json(workflowDef);
        return chakram.wait();
    });
    it("should return a 'not found' error", () => {
        let response = chakram.get(url + "/doesnotexist");
        expect(response).to.have.status(404);
        return chakram.wait();
    });
    workflowDef.description = "Updated description";
    it("should update a workflow def", () => {
        let response = chakram.put(url + "/" + workflowDef.id, workflowDef);
        expect(response).to.have.status(200);
        expect(response).to.comprise.of.json(workflowDef);
        return chakram.wait();
    });
    it("should return an updated workflow def", () => {
        let response = chakram.get(url + "/" + workflowDef.id);
        expect(response).to.have.status(200);
        expect(response).to.comprise.of.json(workflowDef);
        return chakram.wait();
    });
    it("should delete the workflow def", () => {
        let response = chakram.delete(url + "/" + workflowDef.id);
        expect(response).to.have.status(200);
        return chakram.wait();
    });
    it("should return a 'not found' error after document was deleted", () => {
        let response = chakram.get(url + "/doesnotexist");
        expect(response).to.have.status(404);
        return chakram.wait();
    });
});