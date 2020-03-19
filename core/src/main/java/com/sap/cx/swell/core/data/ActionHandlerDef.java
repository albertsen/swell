package com.sap.cx.swell.core.data;

import org.springframework.lang.NonNull;

import java.net.URL;

public class ActionHandlerDef {

    @NonNull
    private String type;
    @NonNull
    private URL url;

    public ActionHandlerDef() {
    }

    public ActionHandlerDef(String type, URL url) {
        this.type = type;
        this.url = url;
    }

    public String getType() {
        return this.type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public URL getUrl() {
        return this.url;
    }

    public void setUrl(URL url) {
        this.url = url;
    }
}
