#!/bin/bash
set -e

/ycsb/bin/ycsb load cassandra-cql -p hosts=$1 $YCSB_LOAD > /dev/null

#drop the caches on the server
curl $1:8082/clear_cache

sleep 10

#bad parameters can lead to painfully slow servers, set a timeout
op=`echo $YCSB_RUN | sed -r 's/.*operationcount=([0-9]+).*/\1/g'`
tg=`echo $YCSB_RUN | sed -r 's/.*target ([0-9]+).*/\1/g'`
echo $op
echo $tg
lim=$(python -c "print int(1.15*$op / $tg)")
echo $lim

timeout $lim /ycsb/bin/ycsb run cassandra-cql -p hosts=$1 -jvm-args "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=7199 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false "  $YCSB_RUN

if [ $? -eq 124 ]; then
	exit 124
fi
#we should add -p cassandra.writeconsistencylevel=QUORUM -p cassandcra.readconsistencylevel=QUORUM
#when we will use more than one server
