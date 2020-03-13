package com.sap.cx.swell.workflow.api.handlers;

import com.sap.cx.swell.workflow.model.Workflow;
import com.sap.cx.swell.workflow.services.WorkflowService;
import com.sap.cx.swell.workflowdef.api.handlers.AbstractCrudHandler;
import com.sap.cx.swell.workflowdef.model.WorkflowDef;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.server.ServerRequest;
import org.springframework.web.reactive.function.server.ServerResponse;
import org.springframework.web.server.ResponseStatusException;
import reactor.core.publisher.Mono;

@Component
public class WorkflowHandler extends AbstractCrudHandler<WorkflowService, Workflow> {

    private WebClient workflowDefWebClient;

    @Autowired
    public WorkflowHandler(WorkflowService workflowService) {
        super(workflowService);
    }

    @Override
    public Mono<ServerResponse> create(ServerRequest request) {
        return request.bodyToMono(Workflow.class)
                .flatMap(this::startWorkwflow)
                .flatMap(getCrudService()::create)
                .flatMap((workflowDef) -> ServerResponse.status(HttpStatus.CREATED).bodyValue(workflowDef));
    }

    private Mono<Workflow> startWorkwflow(Workflow workflow) {
        return workflowDefWebClient.get()
                .uri(workflow.getWorkflowDefId())
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .onStatus(
                        (status) -> status.equals(HttpStatus.NOT_FOUND),
                        clientResponse ->
                                Mono.error(new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY,
                                        String.format("No workflow definition with ID '%s", workflow.getWorkflowDefId())))
                )
                .bodyToMono(WorkflowDef.class)
                .flatMap(this::publishWorklowStartMessage)
                .flatMap((workflowDef) -> Mono.just(workflow));
    }

    private Mono<WorkflowDef> publishWorklowStartMessage(WorkflowDef workflowDef) {
        return Mono.just(workflowDef);
    }

    @Value("${workflowdefService.url}")
    public void setWorkflowDefServiceUrl(String url) {
        this.workflowDefWebClient = WebClient.create(url);
    }
}