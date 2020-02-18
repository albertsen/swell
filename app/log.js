const { createLogger, format, transports } = require('winston');
const { combine, timestamp, label, printf } = format;

const myFormat = printf(info => {
  return `${info.timestamp} [${info.level}]: ${info.message}`;
});

const log = createLogger({
  format: combine(
    timestamp(),
    myFormat
  ),
  transports: [new transports.Console( { level: "debug"})]
});

module.exports = log;