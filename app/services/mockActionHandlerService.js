const express = require("express")
const cors = require("cors")
const HttpStatus = require('http-status-codes');
const bodyParser = require("body-parser");
const asyncHandler = require('express-async-handler')

const log = require("lib/log");
const errorHandler = require("lib/errorHandler");
const rest = require("lib/rest");


const app = express();
app.use(bodyParser.json())
app.use(cors());


app.get("/handle/:action",
    asyncHandler(async (req, res) => {
        let event = req.query["event"];
        rest.sendStatus(res, HttpStatus.OK, {
            event: event,
            doccument: req.body
        });
    })
);

app.use(errorHandler);

app.listen(3010, () => log.info("Mock action handler service listening on port 3010!"));
