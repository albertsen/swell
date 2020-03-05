package main

import (
	"log"
	"net/http"

	wf "github.com/albertsen/swell/pkg/data/workflow"
	"github.com/albertsen/swell/pkg/db"
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
		return echo.NewHTTPError(http.StatusUnprocessableEntity, "Document can't have an ID. It will be assigned by the system.")
	}
	_, err := repo.Create(&workflow)
	if err != nil {
		return err
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
