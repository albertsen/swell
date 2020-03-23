package com.sap.cx.swell.core.config;

import com.rabbitmq.client.BuiltinExchangeType;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.sap.cx.swell.core.constants.Messaging;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import reactor.core.publisher.Mono;
import reactor.rabbitmq.*;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.util.Collections;
import java.util.concurrent.TimeoutException;

@Configuration
public class RabbitMqToplogyConfig {

    private static final Logger LOG = LoggerFactory.getLogger(RabbitMqToplogyConfig.class);

    private final Mono<Connection> connection;

    public RabbitMqToplogyConfig(Mono<Connection> connection) {
        this.connection = connection;
    }

    @Bean
    public Sender sender() {
        return RabbitFlux.createSender(new SenderOptions().connectionMono(connection));
    }

    @Bean
    public Receiver receiver() {
        return RabbitFlux.createReceiver(new ReceiverOptions().connectionMono(connection));
    }

    @PostConstruct
    public void setUpTopology() throws IOException, TimeoutException {
        LOG.info("Setting up RabbitMQ topology");
        Connection conn = null;
        Channel chann = null;
        try {
            // This is blocking because we wan to make sure topology is set up before we carry on
            conn = connection.block();
            chann = conn.createChannel();
            chann.exchangeDeclare(Messaging.Exchanges.ACTIONS, BuiltinExchangeType.FANOUT,
                    true, false, Collections.emptyMap());
            chann.queueDeclare(Messaging.Queues.ACTION_REQUESTS, true,
                    false, false, Collections.emptyMap());
            chann.queueBind(Messaging.Queues.ACTION_REQUESTS, Messaging.Exchanges.ACTIONS, "");
        } finally {
            if (chann != null) {
                chann.close();
            }
        }
    }

}
