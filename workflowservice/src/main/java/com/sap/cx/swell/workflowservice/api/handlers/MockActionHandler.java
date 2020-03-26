package com.sap.cx.swell.workflowservice.api.handlers;

import com.sap.cx.swell.actionhandler.data.ActionContext;
import com.sap.cx.swell.actionhandler.data.ActionResult;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.server.ServerRequest;
import org.springframework.web.reactive.function.server.ServerResponse;
import reactor.core.publisher.Mono;

import java.util.Map;
import java.util.NoSuchElementException;

@Component
public class MockActionHandler {

    @SuppressWarnings("unchecked")
    public Mono<ServerResponse> handleAction(ServerRequest request) {
        return request.bodyToMono(ActionContext.class)
                .flatMap((ctx) -> {
                    Map<String, Object> doc = (Map<String, Object>) ctx.getDocument();
                    String event = request
                            .queryParam("event")
                            .orElseThrow(() -> new NoSuchElementException("URL param 'event' is missing"));
                    String status = request
                            .queryParam("status")
                            .orElseThrow(() -> new NoSuchElementException("URL param 'status' is missing"));
                    doc.put("status", status);
                    ActionResult result = new ActionResult()
                            .setEvent(event)
                            .setDocument(doc);
                    return ServerResponse.status(HttpStatus.OK).bodyValue(result);
                });
    }
}
