package com.sap.cx.swell.core.messages;

import com.sap.cx.swell.core.data.ActionHandler;

import java.time.LocalDateTime;

public class ActionRequest {

    private String actionName;
    private LocalDateTime timestamp;
    private String workflowId;
    private String workflowDefId;
    private ActionHandler handler;

    public String getActionName() {
        return actionName;
    }

    public ActionRequest setActionName(String actionName) {
        this.actionName = actionName;
        return this;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public ActionRequest setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
        return this;
    }

    public String getWorkflowId() {
        return workflowId;
    }

    public ActionRequest setWorkflowId(String workflowId) {
        this.workflowId = workflowId;
        return this;
    }

    public String getWorkflowDefId() {
        return workflowDefId;
    }

    public ActionRequest setWorkflowDefId(String workflowDefId) {
        this.workflowDefId = workflowDefId;
        return this;
    }

    public ActionHandler getHandler() {
        return handler;
    }

    public ActionRequest setHandler(ActionHandler handler) {
        this.handler = handler;
        return this;
    }
}
