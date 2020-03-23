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
        return type;
    }

    public ActionHandlerDef setType(String type) {
        this.type = type;
        return this;
    }

    public URL getUrl() {
        return url;
    }

    public ActionHandlerDef setUrl(URL url) {
        this.url = url;
        return this;
    }
}
