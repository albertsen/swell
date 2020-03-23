package com.sap.cx.swell.core.data;

import java.time.LocalDateTime;

public class ActionRequest {

    private LocalDateTime timestamp;
    private String workflowId;
    private String workflowDefId;
    private ActionHandlerDef handlerDef;

    public ActionRequest(String workflowId, String workflowDefId, ActionHandlerDef handlerDef) {
        this.timestamp = LocalDateTime.now();
        this.workflowId = workflowId;
        this.workflowDefId = workflowDefId;
        this.handlerDef = handlerDef;
    }

    public String getWorkflowId() {
        return workflowId;
    }

    public String getWorkflowDefId() {
        return workflowDefId;
    }

    public ActionHandlerDef getHandlerDef() {
        return handlerDef;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }
}
