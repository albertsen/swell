class ValidationError extends Error {

    constructor(errors) {
        super("Validation errors: " + JSON.stringify(errors));
        this.errors = errors;
    }
};

module.exports = ValidationError;