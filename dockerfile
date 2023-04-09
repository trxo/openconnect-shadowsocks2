# 使用Alpine作为基础镜像
FROM alpine:latest

# 安装openconnect以及必要的依赖
RUN apk add --no-cache openconnect iptables

# 安装wget以下载shadowsocks2
RUN apk add --no-cache wget

# 下载并解压shadowsocks2
RUN wget https://github.com/shadowsocks/go-shadowsocks2/releases/download/v0.1.5/shadowsocks2-linux.gz && \
    gzip -d shadowsocks2-linux.gz && \
    chmod +x shadowsocks2-linux && \
    mv shadowsocks2-linux /usr/local/bin/shadowsocks2

# 暴露shadowsocks2所需端口
EXPOSE 8388

# 创建启动脚本
RUN echo "#!/bin/sh" > /start.sh && \
    echo "echo \"Starting OpenConnect...\"" >> /start.sh && \
    echo "echo \$OPENCONNECT_PASSWORD | openconnect -b --pid-file=/var/run/openconnect.pid -u \$OPENCONNECT_USER \$OPENCONNECT_SERVER --passwd-on-stdin" >> /start.sh && \
    echo "if [ \$? -ne 0 ]; then" >> /start.sh && \
    echo "  echo \"OpenConnect failed to start. Exiting...\"" >> /start.sh && \
    echo "  exit 1" >> /start.sh && \
    echo "fi" >> /start.sh && \
    echo "while [ ! -f /var/run/openconnect.pid ]; do sleep 1; done" >> /start.sh && \
    echo "echo \"Starting Shadowsocks2...\"" >> /start.sh && \
    echo "shadowsocks2 -s ss://\$SS_METHOD:\$SS_PASSWORD@:\$SS_PORT -verbose" >> /start.sh && \
    chmod +x /start.sh

# 启动脚本作为容器的入口点
ENTRYPOINT [ "/start.sh" ]
