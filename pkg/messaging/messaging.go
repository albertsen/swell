package messaging

import (
	"encoding/json"
	"fmt"
	"log"
	"reflect"

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

type Consumer struct {
	chann *amqp.Channel
	queue *amqp.Queue
}

func NewPublisher(exchange string) (*Publisher, error) {
	if err := exchangeDeclare(exchange); err != nil {
		return nil, fmt.Errorf("Error declaring exchange '%s': %w", exchange, err)
	}
	return &Publisher{
		exchange: exchange,
		chann:    chann,
	}, nil
}

func NewConsumer(exchange string, queue string) (*Consumer, error) {
	if err := exchangeDeclare(exchange); err != nil {
		return nil, fmt.Errorf("Error declaring exchange '%s': %w", exchange, err)
	}
	q, err := chann.QueueDeclare(
		queue, // name
		true,  // durable
		false, // delete when unused
		false, // exclusive
		false, // no-wait
		nil,   // arguments
	)
	if err != nil {
		return nil, fmt.Errorf("Error declaring queue '%s': %w", queue, err)
	}
	err = chann.QueueBind(
		q.Name, // queue name
		"",     // routing key
		exchange,
		false, // no-wait
		nil,   // arguments
	)
	if err != nil {
		return nil, fmt.Errorf("Error binding queue '%s' to exchange '%s': %w", queue, exchange, err)
	}
	return &Consumer{
		chann: chann,
		queue: &q,
	}, nil
}

func (p *Publisher) Publish(payload interface{}) error {
	body, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("Error marshalling message payload: %w", err)
	}
	log.Printf("Publishing message: %s", body)
	return p.chann.Publish(
		p.exchange, // exhange
		"",         // routing key
		false,      // mandatory
		false,      // immediate
		amqp.Publishing{
			ContentType: "application/json",
			Body:        body,
		})
}

func (c *Consumer) Consume(callback func(payload interface{}) error, payloadType reflect.Type) error {
	msgs, err := c.chann.Consume(
		c.queue.Name, // queue
		"",           // consumer
		false,        // auto-ack
		false,        // exclusive
		false,        // no-local
		false,        // no-wait
		nil,          // args
	)
	if err != nil {
		return fmt.Errorf("Error consuming messages: %w", err)
	}
	forever := make(chan bool)
	go func() {
		for d := range msgs {
			val := reflect.New(payloadType)
			payload := val.Interface()
			err = json.Unmarshal(d.Body, payload)
			if err != nil {
				log.Printf("Error unmarshalling payload: %w", err)
				continue
			}
			err = callback(payload)
			if err != nil {
				log.Printf("Error handling payload: %w", err)
				continue
			}
			d.Ack(false)
		}
	}()
	<-forever
	return nil
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

func exchangeDeclare(exchange string) error {
	return chann.ExchangeDeclare(
		exchange, // name
		"fanout", // type
		true,     // durable
		false,    // auto-deleted
		false,    // internal
		false,    // no-wait
		nil,      // arguments
	)
}
