FROM debian:jessie

MAINTAINER Laurent Bernaille <laurent.bernaille@d2-si.eu>

ENV JAVA_VERSION=8u45-b14
ENV ES_VERSION=1.6

COPY scripts/install_java.sh /tmp/
RUN /tmp/install_java.sh

COPY scripts/install_es.sh /tmp/
RUN /tmp/install_es.sh

COPY scripts/install_es_plugins.sh /tmp/
RUN /tmp/install_es_plugins.sh

COPY config /tmp/config/
COPY scripts/config_es.sh /tmp/
RUN /tmp/config_es.sh

COPY scripts/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9200

ENV JAVA_HOME="/opt/java"
CMD ["/usr/share/elasticsearch/bin/elasticsearch", "-Des.default.path.home=/usr/share/elasticsearch", "-Des.default.path.logs=/var/log/elasticsearch","-Des.default.path.data=/var/lib/elasticsearch","-Des.default.config=/etc/elasticsearch/elasticsearch.yml","-Des.default.path.conf=/etc/elasticsearch"]
