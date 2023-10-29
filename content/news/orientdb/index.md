---
type: news 
title: 🍛 Discovering Orientdb
date: 2023-08-22T03:48:10+02:00
featured: true
draft: false
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Articles
categories:
  - Blog
tags:
  - Databases
  - Java
authors:
  - mozebaltyk
images: [./orientdb/carousel.webp]
---

OrientDB get into the GraphDB category. It's a lightweight DB writen in java which can be embedded in applications. 
One project which have a strong dependencies on Orientdb is the Nexus Repository which carry an embedded OrientDB.

<!--more-->

## A bit of History 

OrientDB was created in 2010 by Luca Garulli, a pionneer in the multi-model databases. Nonetheless, even if OrientDB is a recognized opensource project, since the acquisition by SAP and the leaving of the foundator in 2021, OrientDB looks hardly supproted. The foundator forked the project to ArkadeDB. 

For ArcadeDB the vision stay clearly opensource and it's visible that it's much more dynamic even though the project is only two years old. 

> All things open source moves faster compared to the proprietary world.
>
> -- <cite>Luca Garulli</cite>
> -- [Blog](https://blog.arcadedb.com/welcome-to-arcadedb)

## OrientDB Install 

I will not repeat what other blog or official documentation already described properly. General idea is to download the latest [bundle](https://orientechnologies.github.io/docs/3.2.x/release/3.2/Available-Packages.html), put in a directory, launch the server to setup, and you are good to start.


Another install method would be with container: 

```bash 
podman run -d --name orientdb --restart=unless-stopped \
-v /opt/orientdb/data:/orientdb/databases \
-v /opt/orientdb/config:/orientdb/config \
-v /opt/orientdb/backup:/orientdb/backup \
-e ORIENTDB_ROOT_PASSWORD=password \
-p 2424:2424 -p 2480:2480 \
orientdb:latest

# When you will need to retrieve info
docker inspect -f "{{ .Config.ExposedPorts }}" orientdb
docker inspect -f "{{ .Config.Volumes }}" orientdb
docker inspect -f "{{ .Config.Env }}" orientdb
```

Connect with

```bash
# Normal install
${ORIENTDB_HOME}/bin/console.sh "connect remote:localhost/demodb root"

# Connect to container
podman exec -it orientdb /bin/sh
```

Fine Tuning: 

* `Xmx + diskCache.buffersize < Memory` 

* `diskCache.buffersize > Xmx` Usually better assigning small heap and large disk cache buffer (off-heap memory) 
  [Source](https://orientdb.com/docs/last/tuning/Performance-Tuning.html)

* If the sum of maximum heap and disk cache buffer is too high, it could cause the OS to swap with huge slowdown. (Get back to the first point) 

* Setting *MaxDirectMemorySize* to a very high value should not concern you as it does not mean that OrientDB will consume all 512GB of memory. 
  The size of direct memory consumed by OrientDB is limited by the size of the disk cache (variable storage.diskCache.bufferSize). 
  [Source](https://orientdb.com/docs/last/internals/Embedded-Server.html?highlight=MaxDirectMemorySize#requirements)

* `xms = xmx` Generally a good pratice. 

* `-Dmemory.useUnsafe=false` This one, I do not know what it's for, but does not inspire me confidence... so should we pass it to `true` ?  


To resume, for a server with 24GB memory, this should give a config like this in your `${ORIENTDB_HOME}/bin/server.sh` like the one below:

```bash
ORIENTDB_OPTS_MEMORY="-Xms8G -Xmx8G -XX:MaxDirectMemorySize=512G -Dstorage.diskCache.bufferSize=12400"
```

## Monitoring

After config below, you should be able to see metrics in your dashboard in the *server management* part. 

* Push agent.jar corresponding to your orientdb version inside `${ORIENTDB_HOME}/plugins` directory

* inside `${ORIENTDB_HOME}/bin/server.sh`

```bash
if [ -z "$JAVA_OPTS_SCRIPT" ] ; then
    JAVA_OPTS_SCRIPT="-Djna.nosys=true -XX:+HeapDumpOnOutOfMemoryError -Djava.awt.headless=true -Dfile.encoding=UTF8 -Drhino.opt.level=9 -Dprofiler.autoDump.reset=true -Dprofiler.autoDump.interval=60 -Dprofiler.enabled=true"
fi
```

* inside `${ORIENTDB_HOME}/config/profiler.json`

```json
{
  "enabled": true,
  "server": {
    "enabled": true
  },
  "database": {
    "enabled": true
  },
  "cluster": {
    "enabled": false
  },
  "reporters": {
    "jmx": {
      "enabled": false,
      "domain": "Test"
    },
    "console": {
      "enabled": false,
      "interval": 5000
    },
    "csv": {
      "enabled": false,
      "directory": "/tmp/orientdb-server-metrics.csv",
      "interval": 5000
    },
    "prometheus": {
      "enabled": false
    }
  }
}
```

## Other resources consumptions 

* openfiles on systems 

```bash
lsof -u orientdb | wc -l
```
