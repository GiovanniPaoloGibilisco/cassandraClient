#!/bin/bash
set -e

/ycsb/bin/ycsb load cassandra-cql -p hosts=$1 $YCSB_LOAD > /dev/null

#drop the caches on the server
curl $1:8082/clear_cache

sleep 10

/ycsb/bin/ycsb run cassandra-cql -p hosts=$1 -jvm-args "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=7199 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Xmx4G -Xms4G -XX:+AlwaysPreTouch"  $YCSB_RUN

#we should add -p cassandra.writeconsistencylevel=QUORUM -p cassandcra.readconsistencylevel=QUORUM
#when we will use more than one server
