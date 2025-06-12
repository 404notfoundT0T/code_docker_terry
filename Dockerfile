FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget http://opengene.org/fastp/fastp -O /usr/local/bin/fastp && \
    chmod a+x /usr/local/bin/fastp

RUN mkdir /data
WORKDIR /data

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
