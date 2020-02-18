const HttpStatus = require('http-status-codes');
const ValidationError = require("./errors/ValidationError");
const NotFoundError = require("./errors/NotFoundError");
const JSONValidationError = require("./errors/JSONValidationError");
const ConflictError = require("./errors/ConflictError");
const log = require("./log");
const sendStatus = require("./rest").sendStatus;


const errorMappings = (function(mappings) {
    mappings[ValidationError] = {
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        errorCode: "VALIDATION_ERROR",
        message: "Your input is not valid",
        detailsAttribute: "errors" 
    };
    mappings[JSONValidationError] = {
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        errorCode: "JSON_VALIDATION_ERROR",
        message: "Invalid JSON document",
        detailsAttribute: "errors"
    };
    mappings[ConflictError] = {
        status: HttpStatus.CONFLICT,
        errorCode: "CONFLICT",
        message: "Connflict occured saving document",
        detailsAttribute: "message"
    };
    mappings[NotFoundError] = {
        status: HttpStatus.NOT_FOUND,
        errorCode: "NOT_FOUND",
        message: "The requested resource does not exist"
    }
    return mappings;
})({});


function sendError(res, message, status = 500, code = "ERROR", details = null) {
    let body = {
        errorCode: code,
        message: message
    };
    if (details) {
        body.details = details;
    }
    sendStatus(res, status, body);
};

function errorHandler(err, req, res, next) {
    if (err.stack) {
        log.error(err.stack);
    }
    else {
        log.error(err);
    }
    let errorMapping = errorMappings[err.constructor];
    if (errorMapping) {
        sendError(
            res,
            errorMapping.message,
            errorMapping.status,
            errorMapping.errorCode,
            err[errorMapping.detailsAttribute]
        )
    }
    else if (err.message) {
        sendError(res, err.message);
    }
    else {
        sendError(res, JSON.stringify(err));
    }
};

module.exports = errorHandler;