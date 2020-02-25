const messaging = require("lib/Messaging");
const log = require("lib/log");

async function init() {
  await messaging.connect();
}

init().then(() => {
  messaging.consume("actions", "actionHandlers", (msg) => {
    log.debug(JSON.stringify(msg));
  });
});
