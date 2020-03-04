package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"reflect"

	wfd "github.com/albertsen/swell/pkg/data/workflowdef"
	"github.com/albertsen/swell/pkg/rest/server"
	"github.com/albertsen/swell/pkg/utils"
	"github.com/gorilla/mux"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var (
	dbClient    *mongo.Client
	dbURI       = utils.Getenv("DB_URI", "mongodb://localhost:27017")
	dbName      = utils.Getenv("DB_NAME", "swell")
	dbColection = utils.Getenv("DB_COLLECTION", "workflowDefs")
	listenAddr  = utils.Getenv("LISTEN_ADDR", ":8080")
	router      = mux.NewRouter()
)

type RestHandler struct {
	Handler         func(doc interface{}, params map[string]string) *RestResponse
	DocumentFactory func() interface{}
}

func (rh *RestHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var doc interface{}
	if rh.DocumentFactory != nil {
		var newDoc wfd.WorkflowDef
		log.Printf("Decoding to doc: %s", reflect.TypeOf(newDoc))
		if err := json.NewDecoder(r.Body).Decode(&newDoc); err != nil {
			server.SendError(w, http.StatusUnprocessableEntity, err)
			return
		}
		log.Printf("Decoded to newDoc: %s", reflect.TypeOf(newDoc))
	} else {
		log.Printf("Decoding to object: %s", reflect.TypeOf(doc))
		if err := json.NewDecoder(r.Body).Decode(doc); err != nil {
			server.SendError(w, http.StatusUnprocessableEntity, err)
			return
		}
	}
	log.Printf("Returning to: %s - %s", reflect.TypeOf(doc), doc)
	res := rh.Handler(doc, mux.Vars(r))
	server.SendResponse(w, res.StatusCode, res.Body)

}

type RestResponse struct {
	StatusCode int
	Headers    map[string]string
	Body       interface{}
}

type RestError struct {
	Message string `json:"message"`
}

func NewErrorRestResponse(statusCode int, message interface{}) *RestResponse {
	return &RestResponse{
		StatusCode: statusCode,
		Body: &RestError{
			Message: fmt.Sprintf("%s", message),
		},
	}
}

func WorkflowDefFactory() interface{} {
	return wfd.WorkflowDef{}
}

func Handle(path string,
	handleFunc func(interface{}, map[string]string) *RestResponse,
	docFactory func() interface{}) *mux.Route {
	return router.Handle(path, &RestHandler{
		Handler:         handleFunc,
		DocumentFactory: docFactory,
	})
}

func DBCollection(collection string) *mongo.Collection {
	return dbClient.Database(dbName).Collection(collection)
}

func CreateDocument(c echo.Context) error {
	var workflowDef wfd.WorkflowDef
	if err := c.Bind(&workflowDef); err != nil {
		return echo.NewHTTPError(http.StatusUnprocessableEntity, err)
	}
	res, err := DBCollection(dbColection).InsertOne(context.Background(), workflowDef)
	if err != nil {
		writeException, ok := err.(mongo.WriteException)
		if ok {
			for _, writeError := range writeException.WriteErrors {
				if writeError.Code == 11000 {
					return echo.NewHTTPError(http.StatusConflict, "Document with this ID already exists")
				}
			}
		}
		return err
	}
	switch v := res.InsertedID.(type) {
	case primitive.ObjectID:
		workflowDef.ID = v.Hex()
	case string:
		workflowDef.ID = v
	default:
		return errors.New("Unknown type of inserted ID")
	}
	return c.JSON(http.StatusCreated, workflowDef)
}

func UpdateDocument(c echo.Context) error {
	var workflowDef wfd.WorkflowDef
	if err := c.Bind(&workflowDef); err != nil {
		return echo.NewHTTPError(http.StatusUnprocessableEntity, err)
	}
	id := c.Param("id")
	res := DBCollection(dbColection).FindOneAndReplace(context.Background(), bson.M{"_id": id}, workflowDef)
	if err := res.Err(); err != nil {
		return err
	}
	var updatedWorkflowDef wfd.WorkflowDef
	err := res.Decode(&updatedWorkflowDef)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusOK, updatedWorkflowDef)
}

func GetDocument(c echo.Context) error {
	id := c.Param("id")
	res := DBCollection(dbColection).FindOne(context.Background(), bson.M{"_id": id})
	if res.Err() == mongo.ErrNoDocuments {
		return echo.NewHTTPError(http.StatusNotFound, "Document not found")
	}
	if err := res.Err(); err != nil {
		log.Println(reflect.TypeOf(res))
		return err
	}
	var workflowDef wfd.WorkflowDef
	err := res.Decode(&workflowDef)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusOK, workflowDef)
}

func DeleteDocument(c echo.Context) error {
	id := c.Param("id")
	_, err := DBCollection(dbColection).DeleteOne(context.Background(), bson.M{"_id": id})
	if err != nil {
		return err
	}
	return c.NoContent(http.StatusOK)
}

func main() {
	mc, err := mongo.NewClient(options.Client().ApplyURI(dbURI))
	if err != nil {
		log.Fatal(err)
	}
	err = mc.Connect(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	defer mc.Disconnect(context.Background())
	dbClient = mc
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
