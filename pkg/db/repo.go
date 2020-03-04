package db

import (
	"context"
	"errors"
	"net/http"

	"github.com/labstack/echo"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Repo struct {
	client     *mongo.Client
	collection *mongo.Collection
}

func NewRepo(uri string, dbName string, collection string) (*Repo, error) {
	client, err := mongo.NewClient(options.Client().ApplyURI(uri))
	if err != nil {
		return nil, err
	}
	err = client.Connect(context.Background())
	if err != nil {
		return nil, err
	}
	return &Repo{
		client:     client,
		collection: client.Database(dbName).Collection(collection),
	}, nil
}

func (r *Repo) Create(doc interface{}) (string, error) {
	res, err := r.collection.InsertOne(context.Background(), doc)
	if err != nil {
		writeException, ok := err.(mongo.WriteException)
		if ok {
			for _, writeError := range writeException.WriteErrors {
				if writeError.Code == 11000 {
					return "", echo.NewHTTPError(http.StatusConflict, "Document with this ID already exists")
				}
			}
		}
		return "", err
	}
	switch v := res.InsertedID.(type) {
	case primitive.ObjectID:
		return v.Hex(), nil
	case string:
		return v, nil
	default:
		return "", errors.New("Unknown type of inserted ID")
	}
}

func (r *Repo) Update(id string, doc interface{}, updatedDoc interface{}) error {
	res := r.collection.FindOneAndReplace(context.Background(), bson.M{"_id": id}, doc)
	if err := res.Err(); err != nil {
		return err
	}
	err := res.Decode(&updatedDoc)
	if err != nil {
		return err
	}
	return nil
}

func (r *Repo) Get(id string, doc interface{}) error {
	res := r.collection.FindOne(context.Background(), bson.M{"_id": id})
	if res.Err() == mongo.ErrNoDocuments {
		return echo.NewHTTPError(http.StatusNotFound, "Document not found")
	}
	if err := res.Err(); err != nil {
		return err
	}
	err := res.Decode(doc)
	if err != nil {
		return err
	}
	return nil
}

func (r *Repo) Delete(id string) error {
	_, err := r.collection.DeleteOne(context.Background(), bson.M{"_id": id})
	if err != nil {
		return err
	}
	return nil
}

func (r *Repo) Close() {
	r.client.Disconnect(context.Background())
}
