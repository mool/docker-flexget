FROM alpine:3.15
MAINTAINER mool

ENV VERSION=3.2.9

RUN apk add --no-cache \
      build-base \
      ca-certificates \
      ffmpeg \
      linux-headers \
      gcc \
      make \
      musl-dev \
      tzdata \
      python3 \
      python3-dev && \
    python3 -m ensurepip --upgrade && \
    pip3 install --no-cache-dir \
      python-telegram-bot \
      transmissionrpc && \
    pip3 install --no-cache-dir --upgrade --force-reinstall \
      flexget==$VERSION && \
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
