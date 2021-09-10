ARG ALPINE_TAG=3.14.1
FROM alpine:$ALPINE_TAG as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:$ALPINE_TAG as src-redis

ARG BRANCH=v0.0.0

RUN apk add --no-cache \
 build-base \
 git \
 linux-headers \
 pkgconfig \
 tcl

RUN git clone --branch $BRANCH --depth 1 https://github.com/redis/redis.git

WORKDIR /redis

RUN make

# RUN make test

FROM alpine:$ALPINE_TAG

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone /etc/timezone

EXPOSE 6379

COPY --from=src-redis /redis/src/redis-benchmark /usr/bin/redis-benchmark
COPY --from=src-redis /redis/src/redis-check-aof /usr/bin/redis-check-aof
COPY --from=src-redis /redis/src/redis-check-rdb /usr/bin/redis-check-rdb
COPY --from=src-redis /redis/src/redis-cli /usr/bin/redis-cli
COPY --from=src-redis /redis/src/redis-sentinel /usr/bin/redis-sentinel
COPY --from=src-redis /redis/src/redis-server /usr/bin/redis-server

# COPY redis.conf /etc/redis/redis.conf

RUN mkdir -p /etc/redis /opt/redis-data

ARG USER=redis
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "$USER:$USER" | chpasswd

RUN chown $USER:$USER -R /etc/redis /opt/redis-data

# USER $USER

ENTRYPOINT ["/usr/bin/redis-server"]
# CMD ["redis-server", "/etc/redis/redis.conf"]
