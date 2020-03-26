package com.sap.cx.swell.actionhandler.data;

public class ActionContext {

    private String actionName;
    private Object document;

    public String getActionName() {
        return actionName;
    }

    public ActionContext setActionName(String actionName) {
        this.actionName = actionName;
        return this;
    }

    public Object getDocument() {
        return document;
    }

    public ActionContext setDocument(Object document) {
        this.document = document;
        return this;
    }
}
