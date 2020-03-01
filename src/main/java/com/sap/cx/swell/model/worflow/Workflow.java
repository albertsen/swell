package com.sap.cx.swell.model.worflow;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "workflows")
public class Workflow<T> {

    @Id
    private String id;
    private String workflowDef;
    private String status;
    private T document;

    public Workflow() {
    }

    public Workflow(String id, String workflowDef, String status, T document) {
        this.id = id;
        this.workflowDef = workflowDef;
        this.status = status;
        this.document = document;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getWorkflowDef() {
        return workflowDef;
    }

    public void setWorkflowDef(String workflowDef) {
        this.workflowDef = workflowDef;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public T getDocument() {
        return document;
    }

    public void setDocument(T document) {
        this.document = document;
    }
}
