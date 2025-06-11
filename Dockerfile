FROM ubuntu:22.04

# 安装依赖
RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

# 安装fastp
RUN wget http://opengene.org/fastp/fastp -O /usr/local/bin/fastp && \
    chmod a+x /usr/local/bin/fastp

# 创建工作目录
RUN mkdir /data
WORKDIR /data

# 复制入口脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
