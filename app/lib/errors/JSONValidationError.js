class JSONValidationError extends Error {
 
    constructor(ajv) {
        super(ajv.errorsText());
        this.ajv = ajv;
    }

    get errors() {
        return this.ajv.errors;
    }

}

module.exports = JSONValidationError;