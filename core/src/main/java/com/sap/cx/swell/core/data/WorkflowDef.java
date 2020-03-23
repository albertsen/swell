package com.sap.cx.swell.core.data;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.lang.NonNull;

import java.util.Map;

@Document(collection = "workflowDefs")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class WorkflowDef {

    @Id
    private String id;
    private String description;
    @NonNull
    private Map<String, ActionHandlerDef> actionHandlers;
    @NonNull
    private Map<String, Map<String, String>> steps;

    public WorkflowDef() {
    }

    public String getId() {
        return id;
    }

    public WorkflowDef setId(String id) {
        this.id = id;
        return this;
    }

    public String getDescription() {
        return description;
    }

    public WorkflowDef setDescription(String description) {
        this.description = description;
        return this;
    }

    public Map<String, ActionHandlerDef> getActionHandlers() {
        return actionHandlers;
    }

    public WorkflowDef setActionHandlers(Map<String, ActionHandlerDef> actionHandlers) {
        this.actionHandlers = actionHandlers;
        return this;
    }

    public Map<String, Map<String, String>> getSteps() {
        return steps;
    }

    public WorkflowDef setSteps(Map<String, Map<String, String>> steps) {
        this.steps = steps;
        return this;
    }

    @JsonIgnore
    public ActionHandlerDef getStartHandlerDef() {
        return getHandlerDef("start");
    }

    public ActionHandlerDef getHandlerDef(String name) {
        return actionHandlers.get(name);
    }

    @Override
    public String toString() {
        return "WorkflowDef{" +
                "id='" + id + '\'' +
                '}';
    }
}
