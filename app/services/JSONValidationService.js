const path = require("path");
const JSONValidationError = require("../errors/JSONValidationError")
const ajv = new require("ajv")();

class JSONValidator {

    constructor(schemaName, schemaFile) {
        this.schemaName = schemaName;
        ajv.addSchema(require(schemaFile), schemaName);
    }

    validate(json) {
        if (!json) throw new Error("No JSON data");
        if (typeof json == 'string') {
            json = JSON.parse(json);
        }
        let valid = ajv.validate(this.schemaName, json);
        return {
            valid: valid,
            error: new JSONValidationError(ajv),
        }
    }
}

class JSONValidationService {

    constructor() {
        this.validators = {};
    }

    validate(json, schemaName) {
        let validator = this._getValidator(schemaName);
        return validator.validate(json);
    }

    _getValidator(schemaName) {
        let validator = this.validators[schemaName];
        if (validator) return validator;
        let schemaFile = path.normalize(__dirname + "/../schemas/" + schemaName + ".schema.json");
        return this.validators[schemaName] = new JSONValidator(schemaName, schemaFile);
    }

}

module.exports = new JSONValidationService();