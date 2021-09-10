# redis

[Redis](https://redis.io) is an open source (BSD licensed), in-memory data structure store, used as a database, cache, and message broker. Redis provides data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs, geospatial indexes, and streams. Redis has built-in replication, Lua scripting, LRU eviction, transactions, and different levels of on-disk persistence, and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster.

## Container

### Repositories

- [Source Code](https://github.com/redis/redis)
- [Container](https://hub.docker.com/repository/docker/gautada/redis)

### Versions

- [September 10, 2021](https://redis.io/download) - Active version is 6.2.5 as tag [v6.2.5](https://github.com/redis/redis/tags)

### Manual

#### Build

```
docker build --build-arg ALPINE_TAG=3.14.2 --build-arg BRANCH=v6.2.5 --file Containerfile --tag gitea:dev .
```


flip/flop



## Configuration

### Persistence 
- [Snapshots|https://redis.io/topics/persistence] - currently there is no need for HA on the redis platform.  Persistence is 
achieved using and RDB snapshots located at /var/lib/redis/dump.rdb

### Backup
- Just grab the data at /var/lib/redis/dump.rdb

### Logs
- Log rotate

## Container

### Build Script
```docker build --tag redis:$(date '+%Y-%m-%d')-build . && docker tag redis:$(date '+%Y-%m-%d')-build redis:latest```

### Run Script
```docker run -Pit --rm --name redis redis:latest /bin/bash```

### Deploy Script
```docker tag redis:latest localhost:32000/redis:latest && docker push localhost:32000/redis:latest```


redis-benchmark
redis-check-aof
redis-check-rdb
redis-cli
redis-sentinel
redis-server



### Kubernetes
```
apiVersion: v1
kind: Service
metadata:
  name: redis
  namespace: data
spec:
  ports:
  - port: 6379
    protocol: TCP
    targetPort: 6379
  selector:
    app: redis
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: data
  labels:
    app: redis
spec:
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: localhost:32000/redis:latest
        ports:
        - containerPort: 6379
          name: redis
        volumeMounts:
        - name: redis-data
          mountPath: /var/lib/redis
      volumes:
      - name: redis-data
        persistentVolumeClaim:
          claimName: redis-claim 
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-claim
  namespace: data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  volumeName: pvc-2cd781b7-28fa-4491-9607-7ff3ccdc5360
```
Install Just REDIS cli

cd /tmp
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make
cp src/redis-cli /usr/local/bin/
chmod 755 /usr/local/bin/redis-cli


kubectl edit -n ingress configmap/nginx-ingress-tcp-microk8s-conf
kubectl edit -n ingress daemonset/nginx-ingress-microk8s-controller



