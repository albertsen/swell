package messages

import (
	wfd "github.com/albertsen/swell/pkg/data/documents/workflowdef"
)

type Action struct {
	Name     string             `json:"name,omitempty"`
	Handler  *wfd.ActionHandler `json:"handler,omitempty"`
	Document interface{}        `json:"document,omitempty"`
}
