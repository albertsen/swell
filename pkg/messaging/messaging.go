package messaging

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/albertsen/swell/pkg/utils"
	"github.com/streadway/amqp"
)

var (
	conn  *amqp.Connection
	chann *amqp.Channel
)

type Publisher struct {
	exchange string
	chann    *amqp.Channel
}

func NewPublisher(exchange string) (*Publisher, error) {
	if err := chann.ExchangeDeclare(
		exchange, // name
		"fanout", // type
		true,     // durable
		false,    // auto-deleted
		false,    // internal
		false,    // no-wait
		nil,      // arguments
	); err != nil {
		return nil, fmt.Errorf("Error declaring exchange '%s': %w", exchange, err)
	}
	return &Publisher{
		exchange: exchange,
		chann:    chann,
	}, nil
}

func (p *Publisher) Publish(payload interface{}) error {
	body, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("Error marshalling message payload: %w", err)
	}
	log.Printf("Publishing message: %s", body)
	return chann.Publish(
		p.exchange, // exhange
		"",         // routing key
		false,      // mandatory
		false,      // immediate
		amqp.Publishing{
			ContentType: "application/json",
			Body:        body,
		})
}

func Connect() error {
	var err error
	var url = utils.Getenv("MESSAGING_URI", "amqp://guest:guest@localhost:5672/")
	if conn, err = amqp.Dial(url); err != nil {
		return fmt.Errorf("Error connecting to messaging server at %s: %w", url, err)
	}
	if chann, err = conn.Channel(); err != nil {
		return fmt.Errorf("Error opening channel to messaging server at %s: %w", url, err)
	}
	return nil
}

func Close() {
	chann.Close()
	conn.Close()
}
