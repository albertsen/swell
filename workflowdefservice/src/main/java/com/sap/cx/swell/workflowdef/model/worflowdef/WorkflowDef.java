package com.sap.cx.swell.workflowdef.model.worflowdef;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Map;

@Document(collection = "workflowDefs")
public class WorkflowDef {

    @Id
    private String id;
    private String description;
    private Map<String, ActionHandlerDef> actionHandlers;
    private Map<String, Map<String, String>> steps;

    public WorkflowDef() {
    }

    public WorkflowDef(String id, String description, Map<String, ActionHandlerDef> actionHandlers, Map<String, Map<String, String>> steps) {
        this.id = id;
        this.description = description;
        this.actionHandlers = actionHandlers;
        this.steps = steps;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Map<String, ActionHandlerDef> getActionHandlers() {
        return actionHandlers;
    }

    public void setActionHandlers(Map<String, ActionHandlerDef> actionHandlers) {
        this.actionHandlers = actionHandlers;
    }

    public Map<String, Map<String, String>> getSteps() {
        return steps;
    }

    public void setSteps(Map<String, Map<String, String>> steps) {
        this.steps = steps;
    }
}
