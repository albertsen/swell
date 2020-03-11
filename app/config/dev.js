module.exports = {
    db: {
        url: process.env.DB_URI || "mongodb://localhost:27017",
        dbName: "swell"
    },
    messaging: {
        url: process.env.MESSAGING_URI || "amqp://localhost",
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