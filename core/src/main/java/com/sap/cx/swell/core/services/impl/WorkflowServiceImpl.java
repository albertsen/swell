package com.sap.cx.swell.core.services.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sap.cx.swell.core.constants.Messaging;
import com.sap.cx.swell.core.data.Workflow;
import com.sap.cx.swell.core.data.WorkflowDef;
import com.sap.cx.swell.core.exceptions.InvalidDataException;
import com.sap.cx.swell.core.exceptions.NotFoundException;
import com.sap.cx.swell.core.messages.ActionRequest;
import com.sap.cx.swell.core.repos.WorkflowRepo;
import com.sap.cx.swell.core.services.WorkflowDefService;
import com.sap.cx.swell.core.services.WorkflowService;
import org.reactivestreams.Publisher;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import reactor.core.Exceptions;
import reactor.core.publisher.Mono;
import reactor.rabbitmq.OutboundMessage;
import reactor.rabbitmq.Sender;

@Service
public class WorkflowServiceImpl extends AbstractCrudService<Workflow> implements WorkflowService {

    private static Logger LOG = LoggerFactory.getLogger(WorkflowServiceImpl.class);
    private ObjectMapper objectMapper;
    private Sender sender;
    private WorkflowDefService workflowDefService;

    @Autowired
    public WorkflowServiceImpl(WorkflowRepo repo, WorkflowDefService workflowDefService,
                               Sender sender, ObjectMapper objectMapper) {
        super(repo);
        this.workflowDefService = workflowDefService;
        this.sender = sender;
        this.objectMapper = objectMapper;
    }

    @Override
    public Mono<Workflow> create(Workflow workflow) {
        return workflowDefService.findById(workflow.getWorkflowDefId())
                .onErrorMap(NotFoundException.class, e ->
                        new InvalidDataException("No workflow definition found with ID %s", workflow.getWorkflowDefId()))
                .flatMap((workflowDef) ->
                        super.create(workflow)
                                .flatMap((createdWorkflow) -> Mono.just(new WorkflowData(createdWorkflow, workflowDef))))
                .delayUntil(this::startWorkflow)
                .flatMap((workflowData) -> Mono.just(workflowData.getWorkflow()));

    }

    private Mono<Void> startWorkflow(WorkflowData workflowData) {
        return sender.send(createStartMessage(workflowData));
    }

    private Publisher<OutboundMessage> createStartMessage(WorkflowData workflowData) {
        return Mono.just(workflowData)
                .flatMap((data) -> Mono.just(new ActionRequest()
                        .setActionName("start")
                        .setWorkflowId(workflowData.getWorkflow().getId())
                        .setWorkflowDefId(workflowData.getWorkflowDef().getId())
                        .setHandler(data.getWorkflowDef().getActionHandler("start"))))
                .flatMap((actionRequest) -> {
                    return Mono.fromCallable(() -> {
                        try {
                            return objectMapper.writeValueAsBytes(actionRequest);
                        } catch (JsonProcessingException e) {
                            throw Exceptions.propagate(e);
                        }
                    });
                })
                .flatMap((json) -> Mono.just(new OutboundMessage(Messaging.Exchanges.ACTIONS, "", json)));
    }

    private class WorkflowData {
        private Workflow workflow;
        private WorkflowDef workflowDef;

        private WorkflowData(Workflow workflow, WorkflowDef workflowDef) {
            this.workflow = workflow;
            this.workflowDef = workflowDef;
        }

        public Workflow getWorkflow() {
            return workflow;
        }

        public WorkflowDef getWorkflowDef() {
            return workflowDef;
        }
    }

}