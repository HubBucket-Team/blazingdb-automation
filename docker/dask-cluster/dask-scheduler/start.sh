#!/bin/bash

echo "### supervisord ###"
supervisord -n -c /etc/supervisor/supervisord.conf &
#sleep 5

#echo "### fordwar sockets to ports ###"
#socat -d -d TCP4-LISTEN:9090,fork UNIX-CONNECT:/tmp/calcite.socket &
#socat -d -d TCP4-LISTEN:9091,fork UNIX-CONNECT:/tmp/orchestrator.socket &
#socat -d -d TCP4-LISTEN:9092,fork UNIX-CONNECT:/tmp/ral.socket &

#echo "### jobs ###"
#jobs
#fg % 1
#tail -f /var/log/supervisor/supervisord.log

echo "### dask scheduler ###"
source activate cudf && dask-scheduler --show
