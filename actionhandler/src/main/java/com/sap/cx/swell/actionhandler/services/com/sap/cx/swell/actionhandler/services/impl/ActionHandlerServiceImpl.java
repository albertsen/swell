package com.sap.cx.swell.actionhandler.services.com.sap.cx.swell.actionhandler.services.impl;

import com.rabbitmq.client.Delivery;
import com.sap.cx.swell.actionhandler.services.ActionHandlerService;
import com.sap.cx.swell.core.constants.Messaging;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.rabbitmq.Receiver;

@Service
public class ActionHandlerServiceImpl implements ActionHandlerService {

    private static Logger LOG = LoggerFactory.getLogger(ActionHandlerServiceImpl.class);
    private final Receiver receiver;

    public ActionHandlerServiceImpl(Receiver receiver) {
        this.receiver = receiver;
    }

    @Override
    public void startHandlingRequests() {
        LOG.info("Starting to handle requests");
        Flux<Delivery> deliveryFlux = receiver.consumeNoAck(Messaging.Queues.ACTION_REQUESTS);
        deliveryFlux.subscribe(m -> {
            LOG.info("Received message {}", new String(m.getBody()));
        });
    }
}
