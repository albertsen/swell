package com.sap.cx.swell.core.config;

import com.rabbitmq.client.BuiltinExchangeType;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
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
        Connection conn = null;
        Channel chann = null;
        try {
            // This is blocking because we wan to make sure topology is set up before we carry on
            conn = connection.block();
            chann = conn.createChannel();
            chann.exchangeDeclare("actions", BuiltinExchangeType.FANOUT,
                    true, false, Collections.emptyMap());
            chann.queueDeclare("actionRequests", true,
                    false, false, Collections.emptyMap());
            chann.queueBind("actionRequests", "actions", "");
        } finally {
            if (chann != null) {
                chann.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
    }

}
