package workflowdef

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
