FROM ubuntu:latest
SHELL ["/bin/bash" ,"-o" ,"pipefail", "-c"]
ENV ZOOKEEPER_HOME /opt/zookeeper
ENV ZOOCFGDIR /opt/zookeeper/conf
ENV ZOOKEEPER_USER zookeeper
ENV ZOO_CONF_DIR=/opt/zookeeper/conf \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/data/datalog \
    ZOO_LOG_DIR=/data/logs \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2 \
    ZOO_AUTOPURGE_PURGEINTERVAL=0 \
    ZOO_AUTOPURGE_SNAPRETAINCOUNT=3 \
    ZOO_MAX_CLIENT_CNXNS=60

WORKDIR /opt
# install java + others
RUN apt-get -qq -o=Dpkg::Use-Pty=0 update  && apt-get -qq -o=Dpkg::Use-Pty=0 upgrade -y && apt-get install -y \
wget \
openjdk-8-jre && \
rm -rf /var/lib/apt/lists/*
RUN groupadd -g 1001 -r $ZOOKEEPER_USER && useradd -r -u 1001 -g $ZOOKEEPER_USER $ZOOKEEPER_USER
RUN mkdir /$ZOO_DATA_DIR && mkdir -p $ZOO_LOG_DIR && chown -R $ZOOKEEPER_USER:$ZOOKEEPER_USER $ZOO_DATA_DIR
#Zookeeper port
EXPOSE 2888 \
       3888 \
       2181
#INSTALL ZOOKEEPER
RUN wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz && \
tar -xvzf zookeeper-3.4.14.tar.gz && \
mv zookeeper-3.4.14 $ZOOKEEPER_HOME && \
rm zookeeper-3.4.14.tar.gz && \
#mv $ZOOKEEPER_HOME/conf/zoo_sample.cfg $ZOOKEEPER_HOME/conf/zoo.cfg && \
chown -R $ZOOKEEPER_USER:$ZOOKEEPER_USER $ZOOKEEPER_HOME
COPY ./docker-entrypoint.sh /
USER zookeeper
WORKDIR /opt/zookeeper
ENTRYPOINT [ "/docker-entrypoint.sh" ]
ENV PATH=$PATH:/$ZOOKEEPER_HOME/bin \
    ZOOCFGDIR=$ZOO_CONF_DIR
CMD ["zkServer.sh", "start-foreground"]
