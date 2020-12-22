FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:3.12.1 as src-redis

# ADD http://download.redis.io/redis-stable.tar.gz /redis-stable.tar.gz
# RUN tar xzvf redis-stable.tar.gz

RUN apk add --no-cache
 build-base \
 git \
 linux-headers \
 pkgconfig \
 tcl

git clone --branch v2.0.4-stable --depth 1 https://github.com/redis/redis.git

WORKDIR /redis

RUN make

# RUN make test

FROM alpine:3.12.1

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone /etc/timezone

EXPOSE 6379

COPY --from=src-redis /redis/src/redis-benchmark /usr/bin/redis-benchmark
COPY --from=src-redis /redis/src/redis-check-aof /usr/bin/redis-check-aof
COPY --from=src-redis /redis/src/redis-check-rdb /usr/bin/redis-check-rdb
COPY --from=src-redis /redis/src/redis-cli /usr/bin/redis-cli
COPY --from=src-redis /redis/src/redis-sentinel /usr/bin/redis-sentinel
COPY --from=src-redis /redis/src/redis-server /usr/bin/redis-server


COPY redis.conf /etc/redis/redis.conf

RUN adduser -D -s /bin/sh redis \
 && echo 'redis:redis' | chpasswd \
 && mkdir -p /opt/redis-data \
 && chown -R redis:redis /etc/redis

ENTRYPOINT ["/usr/bin/redis-server"]
# CMD ["redis-server", "/etc/redis/redis.conf"]
