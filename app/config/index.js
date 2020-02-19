const path = require("path")
// TODO: Sanitize path name for security reasons
config = require("./" + (process.env["NODE_ENV"] || "dev"))
module.exports = config