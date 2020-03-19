package com.sap.cx.swell.core.config;

import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import reactor.core.publisher.Mono;
import reactor.rabbitmq.*;

import java.net.URISyntaxException;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;

@Configuration
public class RabbitMqConfig {

    @Value("${messaging.uri}")
    private String uri;

    @Bean()
    public Mono<Connection> rabbitMqConnection() throws NoSuchAlgorithmException, KeyManagementException, URISyntaxException {
        ConnectionFactory connectionFactory = new ConnectionFactory();
        connectionFactory.setUri(uri);
        return Mono.fromCallable(() -> connectionFactory.newConnection("swell")).cache();
    }

    @Bean
    Sender rabbitMqSender(Mono<Connection> connection) {
        return RabbitFlux.createSender(new SenderOptions().connectionMono(connection));
    }

    @Bean
    Receiver rabbitMqReceiver(Mono<Connection> connection) {
        return RabbitFlux.createReceiver(new ReceiverOptions().connectionMono(connection));
    }

}
