package workflowdef

type ActionHandler struct {
	Type string `json:"type"`
	Url  string `json:"url"`
}

type WorkflowDef struct {
	ID             string                    `json:"id" bson:"_id"`
	ActionHandlers map[string]*ActionHandler `json:"actionHandlers"`
	Steps          map[string]*Step          `json:"steps"`
	Name           string                    `json:"name,omitempty"`
}

type Step struct {
	EventMappings map[string]string `json:"-,omitempty"`
}
