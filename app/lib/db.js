const MongoClient = require("mongodb").MongoClient;
const config = require("config/dev").db;
const log = require("lib/log");

var theDB;

(async function () {
    log.info("Conntecting to MongoDB at " + config.url);
    let client = await MongoClient.connect(config.url, { useNewUrlParser: true, useUnifiedTopology: true });
    theDB = client.db(config.dbName);
})();

function db() {
    return theDB;
}

module.exports = db;
