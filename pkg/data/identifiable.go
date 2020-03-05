package data

type Indentifiable interface {
	ID() string
	SetID(id string)
}
