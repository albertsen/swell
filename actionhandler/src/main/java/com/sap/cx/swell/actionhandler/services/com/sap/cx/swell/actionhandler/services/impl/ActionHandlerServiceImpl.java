package com.sap.cx.swell.actionhandler.services.com.sap.cx.swell.actionhandler.services.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.rabbitmq.client.Delivery;
import com.sap.cx.swell.actionhandler.data.ActionContext;
import com.sap.cx.swell.actionhandler.services.ActionHandlerService;
import com.sap.cx.swell.core.constants.Messaging;
import com.sap.cx.swell.core.data.Workflow;
import com.sap.cx.swell.core.data.WorkflowDef;
import com.sap.cx.swell.core.messages.ActionRequest;
import com.sap.cx.swell.core.services.WorkflowDefService;
import com.sap.cx.swell.core.services.WorkflowService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.Exceptions;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.rabbitmq.Receiver;

import java.io.IOException;

import static java.lang.String.format;

@Service
public class ActionHandlerServiceImpl implements ActionHandlerService {

    private static Logger LOG = LoggerFactory.getLogger(ActionHandlerServiceImpl.class);
    private static WebClient webClient = WebClient.create();
    private WorkflowDefService workflowDefService;
    private WorkflowService workflowService;
    private Receiver receiver;
    private ObjectMapper objectMapper;

    public ActionHandlerServiceImpl(Receiver receiver,
                                    ObjectMapper objectMapper,
                                    WorkflowService workflowService,
                                    WorkflowDefService workflowDefService) {
        this.receiver = receiver;
        this.objectMapper = objectMapper;
        this.workflowService = workflowService;
        this.workflowDefService = workflowDefService;
    }

    @Override
    public void startHandlingRequests() {
        LOG.info("Starting to handle requests");
        Flux<Delivery> deliveryFlux = receiver.consumeNoAck(Messaging.Queues.ACTION_REQUESTS);
        deliveryFlux
                .map((msg) -> {
                    try {
                        return objectMapper.readValue(msg.getBody(), ActionRequest.class);
                    } catch (IOException e) {
                        throw Exceptions.propagate(e);
                    }
                })
                .map((actionRequest) -> new ActionData().setActionRequest(actionRequest))
                .flatMap((actionData) -> {
                    String workflowId = actionData.getActionRequest().getWorkflowId();
                    return workflowService.findById(workflowId)
                            .switchIfEmpty(Mono.error(
                                    new IllegalStateException(format("No workflow found for ID '%s'", workflowId))))
                            .map(actionData::setWorkflow);
                })
                .flatMap((actionData) -> {
                    String workflowDefId = actionData.getActionRequest().getWorkflowDefId();
                    return workflowDefService.findById(workflowDefId)
                            .switchIfEmpty(Mono.error(
                                    new IllegalStateException(format("No workflow definition found for ID '%s'", workflowDefId))))
                            .map(actionData::setWorkflowDef);
                })
                .flatMap((actionData) ->
                        webClient
                                .post()
                                .uri(actionData.getActionRequest().getHandler().getUrl().toExternalForm())
                                .bodyValue(new ActionContext()
                                        .setActionName(actionData.getActionRequest().getActionName())
                                        .setDocument(actionData.getWorkflow().getDocument()))
                                .retrieve()
                                .bodyToMono(String.class))
                .subscribe((body) -> {
                    LOG.info("Action returned result: {}", body);
                });
    }

    private class ActionData {
        private ActionRequest actionRequest;
        private Workflow workflow;
        private WorkflowDef workflowDef;

        public ActionRequest getActionRequest() {
            return actionRequest;
        }

        public ActionData setActionRequest(ActionRequest actionRequest) {
            this.actionRequest = actionRequest;
            return this;
        }

        public Workflow getWorkflow() {
            return workflow;
        }

        public ActionData setWorkflow(Workflow workflow) {
            this.workflow = workflow;
            return this;
        }

        public WorkflowDef getWorkflowDef() {
            return workflowDef;
        }

        public ActionData setWorkflowDef(WorkflowDef workflowDef) {
            this.workflowDef = workflowDef;
            return this;
        }
    }


}


