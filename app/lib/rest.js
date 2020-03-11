const log = require("lib/log");

module.exports = {
    sendBody: function(res, status, body) {
        res.status(status);
        if (body) {
            res.json(body)
        }
        else {
            res.json({status: status})
        }
        res.send();
    },
    sendMessages: function(res, status, messages) {
        res.status(status);
        if (!Array.isArray(messages)) {
            messages = [messages]
        }
        res.json({ messages: messages });
        res.send();
    }
}