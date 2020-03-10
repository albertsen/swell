package main

import (
	"fmt"
	"log"
	"reflect"

	"github.com/albertsen/swell/pkg/data/messages"
	"github.com/albertsen/swell/pkg/messaging"
)

func main() {
	var err error
	err = messaging.Connect()
	if err != nil {
		log.Fatal(err)
	}
	defer messaging.Close()
	consumer, err := messaging.NewConsumer("actions", "actiondispatchrequests")
	payloadType := reflect.TypeOf(messages.Action{})
	log.Println("Starting action dispatcher")
	err = consumer.Consume(handleMessage, payloadType)
	if err != nil {
		log.Fatalf("Error setting up consumer: %s", err)
	}
}

func handleMessage(payload interface{}) error {
	action, ok := payload.(*messages.Action)
	if !ok {
		return fmt.Errorf("Unexpected type of message payload: %s", reflect.TypeOf(action))
	}
	log.Printf(action.Handler.Url)
	return nil
}
