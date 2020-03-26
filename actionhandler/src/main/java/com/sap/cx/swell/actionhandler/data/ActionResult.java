package com.sap.cx.swell.actionhandler.data;

public class ActionResult {

    private String event;
    private Object document;

    public String getEvent() {
        return event;
    }

    public ActionResult setEvent(String event) {
        this.event = event;
        return this;
    }

    public Object getDocument() {
        return document;
    }

    public ActionResult setDocument(Object document) {
        this.document = document;
        return this;
    }
}
