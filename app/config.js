const path = require('path');

const environments = {
    dev: {
        db: {
            url: "mongodb://localhost:27017",
            dbName: "swell"
        }
    }
}



module.exports = environments[process.env["NODE_ENV"] || "dev"];