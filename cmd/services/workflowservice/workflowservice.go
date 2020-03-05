package main

import (
	"fmt"
	"log"
	"net/http"

	wf "github.com/albertsen/swell/pkg/data/workflow"
	"github.com/albertsen/swell/pkg/db"
	"github.com/albertsen/swell/pkg/rest/client"
	"github.com/albertsen/swell/pkg/rest/server"
	"github.com/albertsen/swell/pkg/utils"
	"github.com/labstack/echo"
)

var (
	repo                  *db.Repo
	workflowDefServiceURL = utils.Getenv("WORKFLOW_DEF_SERRVICE_URL", "http://workflowdefservice:8080")
)

func StartWorkflow(c echo.Context) error {
	var workflow wf.Workflow
	if err := c.Bind(&workflow); err != nil {
		return echo.NewHTTPError(http.StatusUnprocessableEntity, err)
	}
	if workflow.ID() != "" {
		return echo.NewHTTPError(http.StatusUnprocessableEntity,
			"Document can't have an ID. It will be assigned by the system.")
	}
	if workflow.WorkflowDefID == "" {
		return echo.NewHTTPError(http.StatusUnprocessableEntity,
			"Document doesn't have a workflowDefId.")
	}
	res, err := client.Head(fmt.Sprintf("%s/workflowdefs/%s",
		workflowDefServiceURL, workflow.WorkflowDefID))
	if err != nil {
		return fmt.Errorf("Error checking for workflow def: %s", err)
	}
	if res.StatusCode != http.StatusOK {
		return echo.NewHTTPError(http.StatusUnprocessableEntity,
			fmt.Sprintf("Can't find workflow def with ID: %s", workflow.WorkflowDefID))
	}
	_, err = repo.Create(&workflow)
	if err != nil {
		return fmt.Errorf("Error creating workflow: %s", err)
	}
	return c.JSON(http.StatusCreated, workflow)
}

func GetWorkflow(c echo.Context) error {
	id := c.Param("id")
	var workflow wf.Workflow
	err := repo.Get(id, &workflow)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusOK, workflow)
}

func main() {
	var err error
	repo, err = db.NewRepo(utils.Getenv("DB_COLLECTION", "workflows"))
	if err != nil {
		log.Fatal(err)
	}
	defer repo.Close()
	server.Start(func(e *echo.Echo) {
		e.POST("/workflows", StartWorkflow)
		e.GET("/workflows/:id", GetWorkflow)
	})
}
