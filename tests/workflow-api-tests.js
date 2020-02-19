const chakram = require('chakram');
const url = require("./config").workflowService.url

expect = chakram.expect;

describe("Workflow API", function () {
    it("should create a workflow", () => {
        let response = chakram.post(url + "/workflows", { work: "flow" });
        expect(response).to.have.status(201);
        return chakram.wait();
    });
});
