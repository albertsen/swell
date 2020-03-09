package workflowdef

import "fmt"

type WorkflowDef struct {
	InternalID     string                    `json:"id" bson:"_id,omitempty"`
	ActionHandlers map[string]*ActionHandler `json:"actionHandlers,omitempty"`
	Steps          map[string]*Step          `json:"steps,omitempty"`
	Name           string                    `json:"name,omitempty,omitempty"`
}

func (w *WorkflowDef) ID() string {
	return w.InternalID
}

func (w *WorkflowDef) SetID(id string) {
	w.InternalID = id
}

func (w *WorkflowDef) ActionHandler(name string) (*ActionHandler, error) {
	ah := w.ActionHandlers[name]
	if ah == nil {
		return nil, fmt.Errorf("No handler for action '%s'", name)
	}
	return ah, nil
}

func (w *WorkflowDef) StartActionHandler() (string, *ActionHandler, error) {
	name := "start"
	ah, err := w.ActionHandler(name)
	return name, ah, err
}
