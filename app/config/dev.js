module.exports = {
    db: {
        url: "mongodb://localhost:27017",
        dbName: "swell"
    },
    messaging: {
        url: "amqp://localhost",
        exchanges: {
            actions: {
                type: "fanout",
                options: { durable: true },
                queues: {
                    actionHandlers: {
                        options: {
                            durable: true
                        }
                    }
                }
            }
        }
    }
}