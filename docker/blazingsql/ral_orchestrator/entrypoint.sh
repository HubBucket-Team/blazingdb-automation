#!/bin/sh

echo "### Orchestrator ###"
/usr/bin/blazingdb_orchestator_service 172.21.1.3 8889 9000 172.21.1.2 8890 &

echo "### Ral ###"
/usr/bin/testing-libgdf 1 172.21.1.3 8889 9000 127.0.0.1 8891 9001
