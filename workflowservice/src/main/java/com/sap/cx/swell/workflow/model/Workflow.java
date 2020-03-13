package com.sap.cx.swell.workflow.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "workflows")
public class Workflow {

    @Id
    private String id;
    private String workflowDefId;
    private Object document;


    public Workflow() {
    }

    public Workflow(String id, String workflowDefId, Object document) {
        this.id = id;
        this.workflowDefId = workflowDefId;
        this.document = document;
    }

    public String getId() {
        return this.id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getWorkflowDefId() {
        return this.workflowDefId;
    }

    public void setWorkflowDefId(String workflowDefId) {
        this.workflowDefId = workflowDefId;
    }

    public Object getDocument() {
        return this.document;
    }

    public void setDocument(Object document) {
        this.document = document;
    }
}
