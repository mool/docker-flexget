FROM alpine:3.16
MAINTAINER mool

ENV VERSION=3.2.9

RUN apk add --no-cache \
      ca-certificates \
      ffmpeg \
      tzdata && \
    apk add --no-cache \
      python3 \
      py3-libtorrent-rasterbar && \
    apk add --no-cache --virtual .build-deps \
      build-base \
      linux-headers \
      gcc \
      make \
      musl-dev \
      python3-dev && \
    python3 -m ensurepip --upgrade && \
    pip3 install --no-cache-dir \
      python-telegram-bot==12.8 \
      subliminal \
      transmission-rpc && \
    pip3 install --no-cache-dir --upgrade --force-reinstall \
      flexget==$VERSION && \
    apk del --no-network .build-deps && \
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
