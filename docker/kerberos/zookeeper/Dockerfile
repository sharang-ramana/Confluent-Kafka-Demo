FROM ubuntu:20.04
ENV container docker

RUN apt-get update && apt-get install -y wget gnupg2 software-properties-common curl

RUN curl -sL --http1.1 https://cnfl.io/cli | sh -s -- latest && \
    export CONFLUENT_HOME=$(pwd) && \
    export PATH=$CONFLUENT_HOME/bin:$PATH && \
    confluent --version

RUN wget -qO - https://packages.confluent.io/deb/7.5/archive.key | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/7.5 stable main"
RUN add-apt-repository "deb https://packages.confluent.io/clients/deb $(lsb_release -cs) main"

# 2. Install zookeeper and kafka
RUN apt-get update && apt-get install -y openjdk-17-jdk && apt-get install -y confluent-server=7.5.1-1 && confluent --version && apt-get install -y confluent-platform

# 3. Configure zookeeper for Kerberos
RUN apt-get install -y krb5-user libkrb5-dev
RUN apt-get clean
COPY zookeeper.properties /etc/kafka/zookeeper.properties
COPY zookeeper.sasl.jaas.config /etc/kafka/zookeeper_server_jaas.conf

EXPOSE 2181

ENV KAFKA_OPTS=-Djava.security.auth.login.config=/etc/kafka/zookeeper_server_jaas.conf

CMD zookeeper-server-start /etc/kafka/zookeeper.properties