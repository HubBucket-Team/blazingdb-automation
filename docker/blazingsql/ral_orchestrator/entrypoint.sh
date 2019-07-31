#!/bin/bash
# Usage: ip_calcite ip_listening

IP_CALCITE=$1
if [ -z $1 ];
then
  IP_CALCITE="172.21.1.2"
fi

IP_LISTENING=$2
if [ -z $2 ];
then
  IP_LISTENING="172.21.1.3"
fi

echo "### Entrypoint ###"
echo "IP CALCITE: $IP_CALCITE"
echo "IP LISTENING: $IP_LISTENING"

echo "### Orchestrator ###"
#/usr/bin/blazingdb_orchestator_service 172.21.1.3 8889 9000 172.21.1.2 8890 &
echo "command: /usr/bin/blazingdb_orchestator_service $IP_LISTENING 8889 9000 $IP_CALCITE 8890 &"
/usr/bin/blazingdb_orchestator_service $IP_LISTENING 8889 9000 $IP_CALCITE 8890 &

echo "### Ral ###"
#/usr/bin/testing-libgdf 1 172.21.1.3 8889 9000 127.0.0.1 8891 9001
echo "command: /usr/bin/testing-libgdf 1 $IP_LISTENING 8889 9000 127.0.0.1 8891 9001"
/usr/bin/testing-libgdf 1 $IP_LISTENING 8889 9000 127.0.0.1 8891 9001
