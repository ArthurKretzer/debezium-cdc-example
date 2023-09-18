ARG DEBEZIUM_VERSION
FROM quay.io/debezium/connect:${DEBEZIUM_VERSION}
ENV KAFKA_CONNECT_JDBC_DIR=$KAFKA_CONNECT_PLUGINS_DIR/kafka-connect-jdbc

ARG POSTGRES_VERSION=42.5.1
ARG KAFKA_JDBC_VERSION=5.3.2

USER root
RUN microdnf -y install libaio curl && microdnf clean all

USER kafka

RUN mkdir /tmp/connector

# S3 connector install
RUN curl --create-dirs -LO --output-dir /tmp/connector https://github.com/Aiven-Open/s3-connector-for-apache-kafka/releases/download/v2.14.0/s3-connector-for-apache-kafka-2.14.0.zip && \
    unzip -o /tmp/connector/s3-connector-for-apache-kafka-2.14.0.zip -d /tmp/connector && \
    mv /tmp/connector/s3-connector-for-apache-kafka-2.14.0 /kafka/connect/aiven-kafka-connect-s3 && \
    rm /tmp/connector/s3-connector-for-apache-kafka-2.14.0.zip

# Deploy PostgreSQL JDBC Driver
RUN cd /kafka/libs && curl -sO https://jdbc.postgresql.org/download/postgresql-$POSTGRES_VERSION.jar

# Deploy Kafka Connect JDBC
RUN mkdir $KAFKA_CONNECT_JDBC_DIR && cd $KAFKA_CONNECT_JDBC_DIR &&\
    curl -sO https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/$KAFKA_JDBC_VERSION/kafka-connect-jdbc-$KAFKA_JDBC_VERSION.jar

