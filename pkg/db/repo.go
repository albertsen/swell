package db

import (
	"context"
	"fmt"
	"net/http"
	"reflect"

	"github.com/albertsen/swell/pkg/data"
	"github.com/albertsen/swell/pkg/utils"
	"github.com/google/uuid"
	"github.com/labstack/echo"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/bsontype"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Repo struct {
	client     *mongo.Client
	collection *mongo.Collection
}

func NewRepo(collection string) (*Repo, error) {
	uri := utils.Getenv("DB_URI", "mongodb://localhost:27017")
	dbName := utils.Getenv("DB_NAME", "swell")
	tM := reflect.TypeOf(bson.M{})
	reg := bson.NewRegistryBuilder().RegisterTypeMapEntry(bsontype.EmbeddedDocument, tM).Build()
	clientOpts := options.Client().SetRegistry(reg).ApplyURI(uri)
	client, err := mongo.NewClient(clientOpts)
	if err != nil {
		return nil, fmt.Errorf("Error creating database client: %w", err)
	}
	err = client.Connect(context.Background())
	if err != nil {
		return nil, fmt.Errorf("Error connection to database: %w", err)
	}
	return &Repo{
		client:     client,
		collection: client.Database(dbName).Collection(collection),
	}, nil
}

func (r *Repo) Create(doc data.Indentifiable) (string, error) {
	if doc.ID() == "" {
		uuid := uuid.New()
		doc.SetID(uuid.String())
	}
	_, err := r.collection.InsertOne(context.Background(), doc)
	if err != nil {
		writeException, ok := err.(mongo.WriteException)
		if ok {
			for _, writeError := range writeException.WriteErrors {
				if writeError.Code == 11000 {
					return "", echo.NewHTTPError(http.StatusConflict, "Document with this ID already exists")
				}
			}
		}
		return "", fmt.Errorf("Error creating document: %w", err)
	}
	return doc.ID(), nil
}

func (r *Repo) Update(id string, doc data.Indentifiable, updatedDoc data.Indentifiable) error {
	if id != doc.ID() {
		return echo.NewHTTPError(http.StatusUnprocessableEntity,
			fmt.Sprintf("Id in URL [%s] and document [%s] don't match", id, doc.ID()))
	}
	res := r.collection.FindOneAndReplace(context.Background(), bson.M{"_id": id}, doc)
	if err := res.Err(); err != nil {
		return fmt.Errorf("Error updating document: %w", err)
	}
	err := res.Decode(updatedDoc)
	if err != nil {
		return fmt.Errorf("Error decoding document: %w", err)
	}
	return nil
}

func (r *Repo) Get(id string, doc data.Indentifiable) error {
	res := r.collection.FindOne(context.Background(), bson.M{"_id": id})
	if res.Err() == mongo.ErrNoDocuments {
		return echo.NewHTTPError(http.StatusNotFound, "Document not found")
	}
	if err := res.Err(); err != nil {
		return fmt.Errorf("Error finding document: %w", err)
	}
	err := res.Decode(doc)
	if err != nil {
		return fmt.Errorf("Error decoding document: %w", err)
	}
	return nil
}

func (r *Repo) Exists(id string) (bool, error) {
	cursor, err := r.collection.Find(context.Background(),
		bson.M{"_id": id},
		options.Find().SetLimit(1))
	if err != nil {
		return false, echo.NewHTTPError(http.StatusInternalServerError, fmt.Errorf("Error finding document: %w", err))
	}
	if exists := cursor.TryNext(context.Background()); exists {
		return true, nil
	}
	return false, cursor.Err()
}

func (r *Repo) Delete(id string) error {
	_, err := r.collection.DeleteOne(context.Background(), bson.M{"_id": id})
	if err != nil {
		return fmt.Errorf("Error deleting document: %w", err)
	}
	return nil
}

func (r *Repo) Close() {
	r.client.Disconnect(context.Background())
}
