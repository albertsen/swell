module.exports = {
    db: {
        url: "mongodb://localhost:27017",
        dbName: "swell"
    },
    queue: {
        url: "amqp://localhost",
        exchanges: {
            actions: {
                name: "actions",
                type: "fanout",
                options: { durable: true }
            }
        }
    }
}