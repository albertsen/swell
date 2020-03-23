package com.sap.cx.swell.core.data;

import com.fasterxml.jackson.annotation.JsonInclude;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.lang.NonNull;

@Document(collection = "workflows")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Workflow {

    @Id
    private String id;
    @NonNull
    private String workflowDefId;
    @NonNull
    private Object document;


    public Workflow() {
    }

    public String getId() {
        return id;
    }

    public Workflow setId(String id) {
        this.id = id;
        return this;
    }

    public String getWorkflowDefId() {
        return workflowDefId;
    }

    public Workflow setWorkflowDefId(String workflowDefId) {
        this.workflowDefId = workflowDefId;
        return this;
    }

    public Object getDocument() {
        return document;
    }

    public Workflow setDocument(Object document) {
        this.document = document;
        return this;
    }

    @Override
    public String toString() {
        return "Workflow{" +
                "id='" + id + '\'' +
                '}';
    }
}
