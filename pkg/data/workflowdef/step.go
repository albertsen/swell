package workflowdef

type Step struct {
	EventMappings map[string]string `json:"-,omitempty"`
}
