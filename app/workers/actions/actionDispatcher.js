const messaging = require("lib/Messaging");
const db = require("lib/DB");
const log = require("lib/log");

async function init() {
  await messaging.connect();
  await db.connect();
}

function main() {
  messaging.consume("actions", "actionHandlers", (msg) => {
    log.debug(JSON.stringify(msg));
  });
}

init().then(() => main());
