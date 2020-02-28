package com.sap.cx.swell.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.config.AbstractReactiveMongoConfiguration;
import org.springframework.data.mongodb.core.ReactiveMongoTemplate;
import org.springframework.data.mongodb.repository.config.EnableReactiveMongoRepositories;

import com.mongodb.reactivestreams.client.MongoClient;
import com.mongodb.reactivestreams.client.MongoClients;

@Configuration
@EnableReactiveMongoRepositories(basePackages = "com.sap.cx.swell.repos")
public class MongoConfig extends AbstractReactiveMongoConfiguration {
    private static Logger log = LoggerFactory.getLogger(MongoConfig.class);

    @Value("${db.connectionString}")
    private String connectionString;

    @Value("${db.name}")
    private String dbName;

    @Override
    public MongoClient reactiveMongoClient() {
        System.out.println("****** client " + getDatabaseName());
        return MongoClients.create(connectionString);
    }

    @Override
    protected String getDatabaseName() {
        return dbName;
    }

    @Bean
    public ReactiveMongoTemplate reactiveMongoTemplate() {
        return new ReactiveMongoTemplate(reactiveMongoClient(), getDatabaseName());
    }
}