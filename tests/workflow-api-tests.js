const chakram = require('chakram');
const url = require("./config").workflowService.url
const workflow = require('./data/Workflow.json');

expect = chakram.expect;

describe("Workflow API", function () {
    it("should create a workflow", () => {
        return chakram.post(url + "/workflows", workflow)
            .then((response) => {
                expect(response).to.have.status(201);
                workflow.id = response.body.id;
                expect(response).to.comprise.of.json(workflow);
                return chakram.get(url + "/workflows/" + workflow.id);
            })
            .then((response) => {
                expect(response).to.have.status(200);
                expect(response).to.comprise.of.json(workflow);
            });
    });
});
