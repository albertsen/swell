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
    sendMessage: function(res, status, message) {
        res.status(status);
        res.json({ message: message });
        res.send();
    }
}