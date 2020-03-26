package com.sap.cx.swell.core.data;

import com.fasterxml.jackson.annotation.JsonInclude;
import org.springframework.lang.NonNull;

import java.net.URL;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class ActionHandler {

    @NonNull
    private String type;
    @NonNull
    private URL url;

    public ActionHandler() {
    }

    public ActionHandler(String type, URL url) {
        this.type = type;
        this.url = url;
    }

    public String getType() {
        return type;
    }

    public ActionHandler setType(String type) {
        this.type = type;
        return this;
    }

    public URL getUrl() {
        return url;
    }

    public ActionHandler setUrl(URL url) {
        this.url = url;
        return this;
    }
}
