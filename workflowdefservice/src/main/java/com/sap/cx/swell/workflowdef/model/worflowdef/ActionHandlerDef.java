package com.sap.cx.swell.workflowdef.model.worflowdef;

import java.net.URI;
import java.net.URL;

public class ActionHandlerDef {

    private String type;
    private URL url;

    public ActionHandlerDef() {
    }

    public ActionHandlerDef(String type, URL url) {
        this.type = type;
        this.url = url;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public URL getUrl() {
        return url;
    }

    public void setUrl(URL url) {
        this.url = url;
    }
}
