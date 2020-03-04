package main

import (
	"log"
	"net/http"

	wfd "github.com/albertsen/swell/pkg/data/workflowdef"
	"github.com/albertsen/swell/pkg/db"
	"github.com/albertsen/swell/pkg/utils"
	"github.com/gorilla/mux"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

var (
	repo         *db.Repo
	dbURI        = utils.Getenv("DB_URI", "mongodb://localhost:27017")
	dbName       = utils.Getenv("DB_NAME", "swell")
	dbCollection = utils.Getenv("DB_COLLECTION", "workflowDefs")
	listenAddr   = utils.Getenv("LISTEN_ADDR", ":8080")
	router       = mux.NewRouter()
)

func CreateDocument(c echo.Context) error {
	var workflowDef wfd.WorkflowDef
	if err := c.Bind(&workflowDef); err != nil {
		return echo.NewHTTPError(http.StatusUnprocessableEntity, err)
	}
	if workflowDef.ID == "" {
		return echo.NewHTTPError(http.StatusUnprocessableEntity, "Document doesn't have an ID")
	}
	_, err := repo.Create(workflowDef)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusCreated, workflowDef)
}

func UpdateDocument(c echo.Context) error {
	var workflowDef wfd.WorkflowDef
	if err := c.Bind(&workflowDef); err != nil {
		return echo.NewHTTPError(http.StatusUnprocessableEntity, err)
	}
	id := c.Param("id")
	var updatedWorkflowDef wfd.WorkflowDef
	err := repo.Update(id, workflowDef, &updatedWorkflowDef)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusOK, updatedWorkflowDef)
}

func GetDocument(c echo.Context) error {
	id := c.Param("id")
	var workflowDef wfd.WorkflowDef
	err := repo.Get(id, &workflowDef)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusOK, workflowDef)
}

func DeleteDocument(c echo.Context) error {
	id := c.Param("id")
	err := repo.Delete(id)
	if err != nil {
		return err
	}
	return c.NoContent(http.StatusOK)
}

func main() {
	var err error
	repo, err = db.NewRepo(dbURI, dbName, dbCollection)
	if err != nil {
		log.Fatal(err)
	}
	defer repo.Close()
	e := echo.New()
	e.Use(middleware.LoggerWithConfig(middleware.LoggerConfig{
		Format: "${time_rfc3339} ${method} ${uri} ${status} ${error}\n",
	}))
	e.POST("/workflowdefs", CreateDocument)
	e.GET("/workflowdefs/:id", GetDocument)
	e.PUT("/workflowdefs/:id", UpdateDocument)
	e.DELETE("/workflowdefs/:id", DeleteDocument)
	e.Logger.Fatal(e.Start(listenAddr))

}
