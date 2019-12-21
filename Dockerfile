FROM alpine:3.10
MAINTAINER mool

RUN apk add --no-cache \
      ca-certificates \
      ffmpeg \
      tzdata \
      python3 \
      py3-cryptography && \
    pip3 install --no-cache-dir --upgrade pip setuptools && \
    pip3 install --no-cache-dir \
      python-telegram-bot \
      transmissionrpc && \
    pip3 install --no-cache-dir --upgrade --force-reinstall \
      flexget==2.21.35 && \
    rm -rf \
      /root/.cache \
      /tmp/* \
      /var/cache/apk/*

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main tinyxml2 && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community mediainfo && \
    rm -rf /var/cache/apk/*

# copy local files
COPY files/ /

# add default volumes
VOLUME /config /data
WORKDIR /data

# expose port for flexget webui
EXPOSE 5050 5050/tcp

# run init.sh to set uid, gid, permissions and to launch flexget
RUN chmod +x /scripts/init.sh
CMD ["/scripts/init.sh"]
