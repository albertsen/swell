const amqp = require("amqplib")
const config = require("config").messaging;
const log = require("lib/log");

class Messaging {

    async connect() {
        log.info("Connecting to RabbitMQ at " + config.url);
        let conn = await amqp.connect(config.url);
        this.channel = await conn.createChannel();
        for (let [exName, ex] of Object.entries(config.exchanges)) {
            await this.channel.assertExchange(exName, ex.type, ex.options);
            for (let [queueName, queue] of Object.entries(ex.queues)) {
                await this.channel.assertQueue(queueName, queue.options);
                await this.channel.bindQueue(queueName, exName, "");
            };
        };
    }

    publish(exchange, payload) {
        if (!exchange) throw new Error("No exchance given");
        if (!payload) throw new Error ("No payload given");
        if (!config.exchanges[exchange]) throw new Error("Unknown exchange: " + exchange)
        let json = JSON.stringify(payload)
        if (!this.channel.publish(exchange, "", Buffer.from(json, "utf8"))) {
            throw new Error(`Could not publish to exchange [${exchange}] with routing key [${rountingKey}]: ` + json)
        }
    }

    consume(exchange, queue, callback) {
        if (!exchange) throw new Error("No exchance given");
        if (!queue) throw new Error("No queue given");
        if (!callback) throw new Error("No callback given");
        let exConfig = config.exchanges[exchange] 
        if (!exConfig) throw new Error("Invalid exchange: " + exchange);
        if (!exConfig.queues[queue]) throw new Error("Invalid queue: " + queue);
        this.channel.consume(queue, (msg) => {
            try {
                let json = msg.content.toString("utf8");
                let payload = JSON.parse(json);   
                callback(payload);
            }
            catch(error) {
                log.error(error);
            }
            finally {
                this.channel.ack(msg);
            }
        });
    }

}

module.exports = new Messaging();