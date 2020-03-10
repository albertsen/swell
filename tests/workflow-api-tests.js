const chakram = require('chakram');
const url = require("./config").workflowService.url
const workflow = require('./data/Workflow.json');

expect = chakram.expect;

describe("Workflow API", function () {
    it("should create a workflow", () => {
        let response = chakram.post(url + "/workflows", workflow);
        expect(response).to.have.status(201);
        return chakram.wait();
    });
});
