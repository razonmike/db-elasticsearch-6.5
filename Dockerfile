FROM centos:7
USER 0
RUN groupadd -g 1000 elasticsearch && useradd elasticsearch -u 1000 -g 1000

RUN yum makecache && \
    yum -y install wget perl-Digest-SHA

COPY elasticsearch-8.6.0-linux-x86_64.tar.gz /
COPY elasticsearch-8.6.0-linux-x86_64.tar.gz.sha512 /

RUN \
    cd / && \
    shasum -a 512 -c elasticsearch-8.6.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.6.0-linux-x86_64.tar.gz && \
    rm -rf elasticsearch-8.6.0-linux-x86_64.tar.gz && \
    mv /elasticsearch-8.6.0 /var/lib/elasticsearch && \
    chown -R elasticsearch:elasticsearch /var/lib/elasticsearch/

RUN mkdir /var/lib/data /var/lib/logs && \
    chown -R elasticsearch:elasticsearch /var/lib/data /var/lib/logs


COPY elasticsearch.yml /var/lib/elasticsearch/config

USER 1000

CMD ["/var/lib/elasticsearch/bin/elasticsearch"]

EXPOSE 9200 9300