#!/bin/sh
/usr/bin/blazingdb_orchestator_service 8889 9000 127.0.0.1 8890
/usr/bin/testing-libgdf 1 127.0.0.1 8889 9000 127.0.0.1 8891 9001
