FROM docker.io/debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gpg \
    supervisor \
    mosquitto \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/nodesource.gpg \
 && echo "deb https://deb.nodesource.com/node_16.x bullseye main" > /etc/apt/sources.list.d/nodesource.list \
 && curl -fsSL https://repos.influxdata.com/influxdb.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/influxdb.gpg \
 && echo "deb https://repos.influxdata.com/debian bullseye stable" > /etc/apt/sources.list.d/influxdata.list \
 && curl -fsSL https://packages.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/grafana.gpg \
 && echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list \
 && apt-get update \
 && apt-get install -yq --no-install-recommends \
    grafana \
    influxdb \
    nodejs \
 && rm -rf /var/lib/apt/lists/* \
 && npm install --location=global --unsafe-perm \
    node-red \
    node-red-dashboard \
    node-red-node-email \
    node-red-node-serialport \
    node-red-contrib-timeprop \
    node-red-contrib-combine \
    node-red-contrib-influxdb \
    node-red-contrib-pid \
 && npm cache clean --location=global -f \
 && useradd node-red \
 && mkdir -p /data/influxdb/meta /data/influxdb/data /var/tmp/influxdb/wal /data/grafana/plugins /data/node-red /run/mosquitto \
 && chown -R grafana:grafana /data/grafana \
 && chown -R influxdb:influxdb /data/influxdb \
 && chown -R node-red:node-red /data/node-red \
 && chown -R mosquitto:mosquitto /run/mosquitto

COPY influxdb.conf /etc/influxdb/influxdb.conf
COPY services.conf /etc/supervisor/conf.d/services.conf
COPY public.conf /etc/mosquitto/conf.d/public.conf

VOLUME ["/data"]

EXPOSE 1880
EXPOSE 1883
EXPOSE 3000
EXPOSE 8086

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
