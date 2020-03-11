const { v4: uuid } = require('uuid');
const db = require("lib/db");
const ValidationError = require("lib/errors/ValidationError");
const ConflictError = require("lib/errors/ConflictError");
const NotFoundError = require("lib/errors/NotFoundError");

class GenericRepo {

    constructor(collectionName) {
        this.collectionName = collectionName;
    }

    collection() {
        return db.connection.collection(this.collectionName);
    }

    async create(doc) {
        if (!doc) throw new ValidationError("No document given");
        if (doc.id) {
            doc._id = doc.id;
            delete doc.id
        }
        else {
            doc._id = uuid()
        }
        try {
            let res = await this.collection().insertOne(doc);
            doc.id = res.insertedId;
            return doc;
        }
        catch (error) {
            if (error.code == 11000) throw new ConflictError("There is already a document with the ID: " + doc.id);
            throw error;
        }
    }

    async findOneById(id) {
        if (!id) throw new ValidationError("No ID given");
        let doc = await this.collection().findOne({ _id: id });
        if (!doc) return null
        doc.id = doc._id
        delete doc._id;
        return doc;
    }

    async update(id, doc) {
        if (!id) throw new ValidationError("No ID given");
        if (!doc) throw new ValidationError("No doc given");
        if (id != doc.id) throw new ValidationError("ID in URL and ID in document don't match")
        doc._id = id;
        delete doc.id
        let res = await this.collection().replaceOne({ _id: id }, doc);
        if (res.matchedCount == 0) throw new NotFoundError("Could not find document with ID: " + id)
        doc.id = id
        return doc;
    }

    async delete(id) {
        if (!id) throw new ValidationError("No ID given");
        await this.collection().deleteOne({ _id: id });
        return null;
    }


}

module.exports = GenericRepo;