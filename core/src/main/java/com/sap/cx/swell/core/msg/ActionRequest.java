package com.sap.cx.swell.core.msg;

import com.sap.cx.swell.core.data.ActionHandlerDef;

public class ActionRequest {

    private String workflowId;
    private String workflowDefId;
    private ActionHandlerDef handlerDef;

    public ActionRequest(String workflowId, String workflowDefId, ActionHandlerDef handlerDef) {
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
}
