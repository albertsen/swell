const db = require("lib/db")
const log = require("lib/log");
const ValidationError = require("lib/errors/ValidationError");
const ConflictError = require("lib/errors/ConflictError");
const NotFoundError = require("lib/errors/NotFoundError");

class GenericRepo {

    constructor(collectionName) {
        this.collectionName = collectionName;
    }

    collection() {
        return db().collection(this.collectionName);
    }

    async create(doc) {
        if (!doc) throw new ValidationError("No document given");
        if (doc.id) doc._id = doc.id;
        try {
            await this.collection().insertOne(doc);
            return { 
                message: "Document created",
                id: doc.id 
            }
        }
        catch (error) {
            if (error.code == 11000) throw new ConflictError("There is already a document with the ID: " + doc.id);
            throw error;
        }
    }

    async findById(id) {
        if (!id) throw new ValidationError("No ID given");
        let doc = await this.collection().findOne({ _id: id });
        if (!doc) throw new NotFoundError("Could not find document with ID: " + id)
        delete doc._id;
        return doc;
    }

    async update(id, doc) {
        if (!id) throw new ValidationError("No ID given");
        if (!doc) throw new ValidationError("No doc given");
        if (id != doc.id) throw new ValidationError("ID in URL and ID in document don't match")
        doc._id = id;
        let res = await this.collection().replaceOne({ _id: id }, doc);
        if (res.matchedCount == 0) throw new NotFoundError("Could not find document with ID: " + id)
        return { message: "Document updated" } 
    }

    async delete(id) {
        if (!id) throw new ValidationError("No ID given");
        let res = await this.collection().deleteOne({ _id: id });
        log.debug(JSON.stringify(res));
        return { message: "Document deleted" } ;
    }


}

module.exports = GenericRepo;