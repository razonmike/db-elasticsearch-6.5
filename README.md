Задание 1
В ответе приведите:

текст Dockerfile:

```dockerfile
FROM centos:7
USER 0
RUN groupadd -g 1000 elasticsearch && useradd elasticsearch -u 1000 -g 1000

RUN yum makecache && \
    yum -y install wget perl-Digest-SHA

COPY elasticsearch-8.6.0-linux-x86_64.tar.gz /
COPY elasticsearch-8.6.0-linux-x86_64.tar.gz.sha512 /

RUN \
    cd / && \
    shasum -a 512 -c elasticsearch-8.6.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.6.0-linux-x86_64.tar.gz && \
    rm -rf elasticsearch-8.6.0-linux-x86_64.tar.gz && \
    mv /elasticsearch-8.6.0 /var/lib/elasticsearch && \
    chown -R elasticsearch:elasticsearch /var/lib/elasticsearch/

RUN mkdir /var/lib/data /var/lib/logs && \
    chown -R elasticsearch:elasticsearch /var/lib/data /var/lib/logs


COPY elasticsearch.yml /var/lib/elasticsearch/config

USER 1000

CMD ["/var/lib/elasticsearch/bin/elasticsearch"]

EXPOSE 9200 9300
```

Ссылку на dockerhub:
<https://hub.docker.com/repository/docker/razonmike/elastic-netology/general>

ответ elasticsearch на запрос пути / в json виде

```json
[elasticsearch@f5323d7faa8d /]$ curl http://127.0.0.1:9200
{
  "name" : "elastic-netology",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "71eoG-E7QZuQeExUAa6Y_A",
  "version" : {
    "number" : "8.6.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "f67ef2df40237445caa70e2fef79471cc608d70d",
    "build_date" : "2023-01-04T09:35:21.782467981Z",
    "build_snapshot" : false,
    "lucene_version" : "9.4.2",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

Задание 2
Ознакомтесь с документацией и добавьте в elasticsearch 3 индекса, в соответствии со таблицей:

```json
curl -XPUT "http://localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1, "number_of_replicas": 0 } }'
curl -XPUT "http://localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 2, "number_of_replicas": 1 } }'
curl -XPUT "http://localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4, "number_of_replicas": 2 } }'
```

Получите список индексов и их статусов, используя API и приведите в ответе на задание:

```bash
[elasticsearch@7abf44d741ff /]$ curl -X GET "127.0.0.1:9200/_cat/indices/ind-*?v=true&s=index&pretty"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 pfcEx1MDT_y2C6CfDPedRQ   1   0          0            0       225b           225b
yellow open   ind-2 TF2Zxaz2TI2q98BP1Ibl3w   2   1          0            0       450b           450b
yellow open   ind-3 JowyUoPcR6ChDnlFWtPgbw   4   2          0            0       900b           900b
```

Получите состояние кластера elasticsearch, используя API:

```bash
[elasticsearch@7abf44d741ff /]$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
Я думаю что, в параметрах создания индексов количество реплик больше 1 и в кластере тоже 1 нода, поэтому 2 и 3 индексы не реплицируются.

Удалите все индексы

```bash
curl -XDELETE "http://localhost:9200/ind-1?pretty"
curl -XDELETE "http://localhost:9200/ind-2?pretty"
curl -XDELETE "http://localhost:9200/ind-3?pretty"
```

Задание 3

Используя API зарегистрируйте данную директорию как snapshot repository c именем netology_backup.

```bash
[elasticsearch@7abf44d741ff /]$ curl -X PUT "127.0.0.1:9200/_snapshot/netology_backup?&pretty" -H 'Content-Type: application/json' -d' { "type": "fs", "settings": { "location": "/var/lib/elasticsearch/snapshots" } }'
{
  "acknowledged" : true
}
```

Создайте индекс test с 0 реплик и 1 шардом и приведите в ответе список индексов.

```bash
[elasticsearch@7abf44d741ff /]$ curl -X GET "127.0.0.1:9200/_cat/indices/*?v=true&s=index&pretty"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  a65haYqoT0OyNhqJAf7VcQ   1   0          0            0       225b           225b
```

Создайте snapshot состояния кластера elasticsearch.

```bash
elasticsearch@7abf44d741ff /]$ curl -X PUT "127.0.0.1:9200/_snapshot/netology_backup/my_snapshot_1?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "my_snapshot_1",
    "uuid" : "oATY4tQAR4OUETJoXGwZtA",
    "repository" : "netology_backup",
    "version_id" : 8060099,
    "version" : "8.6.0",
    "indices" : [
      ".geoip_databases",
      "test"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2023-01-21T15:54:41.320Z",
    "start_time_in_millis" : 1674316481320,
    "end_time" : "2023-01-21T15:54:42.521Z",
    "end_time_in_millis" : 1674316482521,
    "duration_in_millis" : 1201,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}
```

Приведите в ответе список файлов в директории со snapshotами.

```bash
[elasticsearch@7abf44d741ff /]$ ll /var/lib/elasticsearch/snapshots/
total 32
-rw-r--r--. 1 elasticsearch elasticsearch   846 Jan 21 15:54 index-0
-rw-r--r--. 1 elasticsearch elasticsearch     8 Jan 21 15:54 index.latest
drwxr-xr-x. 4 elasticsearch elasticsearch    66 Jan 21 15:54 indices
-rw-r--r--. 1 elasticsearch elasticsearch 18497 Jan 21 15:54 meta-oATY4tQAR4OUETJoXGwZtA.dat
-rw-r--r--. 1 elasticsearch elasticsearch   356 Jan 21 15:54 snap-oATY4tQAR4OUETJoXGwZtA.dat
```

Удалите индекс test и создайте индекс test-2. Приведите в ответе список индексов.

```bash
[elasticsearch@7abf44d741ff /]$ curl -X GET "127.0.0.1:9200/_cat/indices/*?v=true&s=index&pretty"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 6VyZtK3bR9ST0MfdwoOleA   1   0          0            0       225b           225b
```

Восстановите состояние кластера elasticsearch из snapshot, созданного ранее.

```bash
[elasticsearch@7abf44d741ff /]$ curl -X POST "127.0.0.1:9200/_snapshot/netology_backup/my_snapshot_1/_restore?pretty" -H 'Content-Type: application/json' -d' { "indices": "*", "include_global_state": true } '
{
  "accepted" : true
}
```

```bash
[elasticsearch@7abf44d741ff /]$ curl -X GET "127.0.0.1:9200/_cat/indices/*?v=true&s=index&pretty"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test   HQ4bMLZRTCudtLQzB0ScqA   1   0          0            0       225b           225b
green  open   test-2 6VyZtK3bR9ST0MfdwoOleA   1   0          0            0       225b           225b
```
