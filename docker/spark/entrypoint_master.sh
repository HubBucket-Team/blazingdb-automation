#!/bin/bash

/usr/local/spark/sbin/start-master.sh --host $1 &&\
tail -f /usr/local/spark/logs/spark--org.apache.spark.deploy.master.*.out
