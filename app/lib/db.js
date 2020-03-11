const MongoClient = require("mongodb").MongoClient;
const config = require("config/dev").db;
const log = require("lib/log");

class DB {
    async connect() {
        log.info("Connecting to MongoDB at " + config.url);
        let client = await MongoClient.connect(config.url, { useNewUrlParser: true, useUnifiedTopology: true });
        this.connection = client.db(config.dbName);
    };
};

module.exports = new DB();
