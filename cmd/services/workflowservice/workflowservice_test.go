package main

import (
	"fmt"
	"net/http"
	"testing"

	wf "github.com/albertsen/swell/pkg/data/documents/workflow"
	"github.com/albertsen/swell/pkg/rest/client"
	tu "github.com/albertsen/swell/pkg/testing/utils"
	"github.com/stretchr/testify/assert"
)

var (
	workflowServiceURL = "http://localhost:8081/workflows"
)

func TestCRUD(t *testing.T) {
	var refWorkflow wf.Workflow
	err := tu.LoadData("../../../test/data/workflow.json", &refWorkflow)
	if err != nil {
		t.Fatal(err)
	}
	var createdWorkflow wf.Workflow
	res, err := client.Post(workflowServiceURL, &refWorkflow, &createdWorkflow)
	if err != nil {
		t.Fatal(err)
	}
	assert.Equal(t, http.StatusCreated, res.StatusCode, res.Message)
	if createdWorkflow.ID() == "" {
		t.Fatal("Workflow ID is empty")
	}
	refWorkflow.SetID(createdWorkflow.ID())
	assert.EqualValues(t, refWorkflow, createdWorkflow)
	workflowURL := workflowServiceURL + "/" + refWorkflow.ID()
	var storedWorkflow wf.Workflow
	res, err = client.Get(workflowURL, &storedWorkflow)
	assert.Equal(t, http.StatusOK, res.StatusCode, fmt.Sprintf("HTTP status should be OK - %s", res))
	assert.EqualValues(t, &refWorkflow, &storedWorkflow, "Reference order and stored order are not equal")

	invalidWorkflow := &wf.Workflow{
		WorkflowDefID: "invalid",
		Document:      map[string]bool{"valid": false},
	}
	res, err = client.Post(workflowServiceURL, invalidWorkflow, &createdWorkflow)
	assert.Equal(t, http.StatusUnprocessableEntity, res.StatusCode, res.Message)

}
