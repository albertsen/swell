package main

import (
	"fmt"
	"log"
	"net/http"

	wf "github.com/albertsen/swell/pkg/data/documents/workflow"
	wfd "github.com/albertsen/swell/pkg/data/documents/workflowdef"
	"github.com/albertsen/swell/pkg/data/messages"
	"github.com/albertsen/swell/pkg/db"
	"github.com/albertsen/swell/pkg/messaging"
	"github.com/albertsen/swell/pkg/rest/client"
	"github.com/albertsen/swell/pkg/rest/server"
	"github.com/albertsen/swell/pkg/utils"
	"github.com/labstack/echo"
)

var (
	repo                  *db.Repo
	workflowDefServiceURL = utils.Getenv("WORKFLOW_DEF_SERRVICE_URL", "http://workflowdefservice:8080")
	publisher             *messaging.Publisher
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

	var workflowDef wfd.WorkflowDef
	res, err := client.Get(fmt.Sprintf("%s/workflowdefs/%s",
		workflowDefServiceURL, workflow.WorkflowDefID), &workflowDef)
	if err != nil {
		if res.StatusCode == http.StatusNotFound {
			return echo.NewHTTPError(http.StatusUnprocessableEntity,
				fmt.Sprintf("Invalid workflode def ID: %s", workflow.WorkflowDefID))
		}
		return fmt.Errorf("Error retrieving workflow def with id '%s': %w",
			workflow.WorkflowDefID, err)
	}

	_, err = repo.Create(&workflow)
	if err != nil {
		return fmt.Errorf("Error creating workflow: %s", err)
	}

	actionName, actionHandler, err := workflowDef.StartActionHandler()
	if err != nil {
		return fmt.Errorf("Error getting start action from workflow def with ID '%s: %w", workflowDef.ID(), err)
	}

	publisher.Publish(&messages.Action{
		Name:    actionName,
		Handler: actionHandler,
	})

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
	err = messaging.Connect()
	if err != nil {
		log.Fatal(err)
	}
	defer messaging.Close()
	publisher, err = messaging.NewPublisher("actions")
	if err != nil {
		log.Println(err)
		log.Fatal(err)
	}
	server.Start(func(e *echo.Echo) {
		e.POST("/workflows", StartWorkflow)
		e.GET("/workflows/:id", GetWorkflow)
	})
}
