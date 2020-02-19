module.exports = {
    sendStatus: function(res, status, body) {
        res.status(status);
        if (body) {
            res.json(body)
        }
        else {
            res.json({status: status})
        }
        res.send();
    }
}