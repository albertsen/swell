const MongoClient = require("mongodb").MongoClient;
const config = require("./config").db;
const log = require("./log");

var theDB;

(async function() {
    log.info("Conntecting to MongoDB at " + config.url);
    let client = await MongoClient.connect(config.url, { useNewUrlParser: true} );
    theDB = client.db(config.dbName);
})();

function db() {
    return theDB;
}

module.exports = db;
