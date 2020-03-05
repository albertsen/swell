package server

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/albertsen/swell/pkg/utils"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

type errorMessage struct {
	Message string `json:"message"`
}

func SendOK(w http.ResponseWriter, data interface{}) {
	SendResponse(w, http.StatusOK, data)
}

func SendError(w http.ResponseWriter, status int, message interface{}) {
	messageString := fmt.Sprintf("%s", message)
	SendResponse(w, status, errorMessage{Message: messageString})
}

func SendResponse(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(statusCode)
	if data != nil {
		json.NewEncoder(w).Encode(data)
	}
}

func SendResponseOrError(w http.ResponseWriter, expectedStatusCode int, actualStatusCode int, data interface{}, err error) {
	if actualStatusCode != expectedStatusCode {
		SendError(w, actualStatusCode, err)
	} else {
		SendResponse(w, expectedStatusCode, data)
	}
}

func Start(config func(*echo.Echo)) {
	e := echo.New()
	e.Use(middleware.LoggerWithConfig(middleware.LoggerConfig{
		Format: "${time_rfc3339} ${method} ${uri} ${status} ${error}\n",
	}))
	config(e)
	listenAddr := utils.Getenv("LISTEN_ADDR", ":8080")
	e.Logger.Fatal(e.Start(listenAddr))
}
