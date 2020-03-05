package workflow

type Workflow struct {
	InternalID    string                 `json:"id" bson:"_id,omitempty"`
	WorkflowDefID string                 `json:"workflowDefId,omitempty"`
	Document      map[string]interface{} `json:"document,omitempty"`
}

func (w *Workflow) ID() string {
	return w.InternalID
}

func (w *Workflow) SetID(id string) {
	w.InternalID = id
}
