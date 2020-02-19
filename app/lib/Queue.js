const amqp = require("amqplib")
const config = require("../config").queue;
const log = require("./log");

class Queue {

    constructor() {
        (async function (queue) {
            log.info("Connecting to RabbitMQ at " + config.url);
            let conn = await amqp.connect(config.url);
            queue.channel = await conn.createChannel();
            Object.values(config.exchanges).forEach(async (ex) => {
                await queue.channel.assertExchange(ex.name, ex.type, ex.options)
            });
        })(this);
    }

    publish(exchange, rountingKey, payload) {
        let exchangeName = config.exchanges[exchange].name
        if (!exchangeName) throw new Error("Unknown exchange: " + exchange)
        let json = JSON.stringify(payload)
        this.channel.publish(exchangeName, rountingKey, Buffer.from(json))
    }

}

module.exports = new Queue();