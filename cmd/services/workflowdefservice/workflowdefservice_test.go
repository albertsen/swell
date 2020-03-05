package main

import (
	"fmt"
	"net/http"
	"testing"

	wfd "github.com/albertsen/swell/pkg/data/workflowdef"
	"github.com/albertsen/swell/pkg/rest/client"
	tu "github.com/albertsen/swell/pkg/testing/utils"
	"github.com/stretchr/testify/assert"
)

var (
	workflowDefServiceURL = "http://localhost:8080/workflowdefs"
)

func TestCRUD(t *testing.T) {
	var refWorkflowDef wfd.WorkflowDef
	err := tu.LoadData("../../../test/data/workflowdef.json", &refWorkflowDef)
	if err != nil {
		t.Fatal(err)
	}
	var createdWorkflowDef wfd.WorkflowDef
	res, err := client.Post(workflowDefServiceURL, &refWorkflowDef, &createdWorkflowDef)
	if err != nil {
		t.Fatal(err)
	}
	assert.Equal(t, http.StatusCreated, res.StatusCode, res.Message)
	assert.EqualValues(t, refWorkflowDef, createdWorkflowDef)
	// Creating a second document with the same ID should raise an conflict
	res, err = client.Post(workflowDefServiceURL, &refWorkflowDef, &createdWorkflowDef)
	assert.Equal(t, http.StatusConflict, res.StatusCode, res.Message)
	workflowDefURL := workflowDefServiceURL + "/" + refWorkflowDef.ID()
	var storedWorkflowDef wfd.WorkflowDef
	res, err = client.Get(workflowDefURL, &storedWorkflowDef)
	if err != nil {
		t.Fatal(err)
	}
	assert.Equal(t, http.StatusOK, res.StatusCode, fmt.Sprintf("HTTP status should be OK - %s", res))
	assert.EqualValues(t, &refWorkflowDef, &storedWorkflowDef, "Reference order and stored order are not equal")
	refWorkflowDef.Name = "New name"
	res, err = client.Put(workflowDefURL, refWorkflowDef, nil)
	if err != nil {
		t.Fatal(err)
	}
	assert.Equal(t, http.StatusOK, res.StatusCode, fmt.Sprintf("HTTP status should be OK - %s", res))
	res, err = client.Get(workflowDefURL, &storedWorkflowDef)
	if err != nil {
		t.Fatal(err)
	}
	assert.Equal(t, http.StatusOK, res.StatusCode, fmt.Sprintf("HTTP status should be OK - %s", res))
	assert.EqualValues(t, &refWorkflowDef, &storedWorkflowDef, "Reference order and stored order are not equal")
	res, err = client.Delete(workflowDefURL)
	if err != nil {
		t.Fatal(err)
	}
	assert.Equal(t, http.StatusOK, res.StatusCode, fmt.Sprintf("HTTP status should be OK - %s", res))
	// Second delete should not raise an error because it's supposed to be indempotent
	res, err = client.Delete(workflowDefURL)
	if err != nil {
		t.Fatal(err)
	}
	assert.Equal(t, http.StatusOK, res.StatusCode, fmt.Sprintf("HTTP status should be OK - %s", res))
	res, err = client.Get(workflowDefURL, &storedWorkflowDef)
	assert.Equal(t, res.StatusCode, http.StatusNotFound, fmt.Sprintf("HTTP status should be NOT FOUND - %s", res))
}
