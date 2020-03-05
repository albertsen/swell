package main

import (
	"log"
	"net/http"

	wfd "github.com/albertsen/swell/pkg/data/workflowdef"
	"github.com/albertsen/swell/pkg/db"
	"github.com/albertsen/swell/pkg/rest/server"
	"github.com/albertsen/swell/pkg/utils"
	"github.com/labstack/echo"
)

var (
	repo *db.Repo
)

func CreateWorkflowDef(c echo.Context) error {
	var workflowDef wfd.WorkflowDef
	if err := c.Bind(&workflowDef); err != nil {
		return echo.NewHTTPError(http.StatusUnprocessableEntity, err)
	}
	if workflowDef.ID() == "" {
		return echo.NewHTTPError(http.StatusUnprocessableEntity, "Document doesn't have an ID")
	}
	_, err := repo.Create(&workflowDef)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusCreated, workflowDef)
}

func UpdateWorkflowDef(c echo.Context) error {
	var workflowDef wfd.WorkflowDef
	if err := c.Bind(&workflowDef); err != nil {
		return echo.NewHTTPError(http.StatusUnprocessableEntity, err)
	}
	id := c.Param("id")
	var updatedWorkflowDef wfd.WorkflowDef
	err := repo.Update(id, &workflowDef, &updatedWorkflowDef)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusOK, updatedWorkflowDef)
}

func GetWorkflowDef(c echo.Context) error {
	id := c.Param("id")
	var workflowDef wfd.WorkflowDef
	err := repo.Get(id, &workflowDef)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusOK, workflowDef)
}

func DeleteWorkflowDef(c echo.Context) error {
	id := c.Param("id")
	err := repo.Delete(id)
	if err != nil {
		return err
	}
	return c.NoContent(http.StatusOK)
}

func main() {
	var err error
	repo, err = db.NewRepo(utils.Getenv("DB_COLLECTION", "workflowDefs"))
	if err != nil {
		log.Fatal(err)
	}
	defer repo.Close()
	server.Start(func(e *echo.Echo) {
		e.POST("/workflowdefs", CreateWorkflowDef)
		e.GET("/workflowdefs/:id", GetWorkflowDef)
		e.PUT("/workflowdefs/:id", UpdateWorkflowDef)
		e.DELETE("/workflowdefs/:id", DeleteWorkflowDef)
	})
}
