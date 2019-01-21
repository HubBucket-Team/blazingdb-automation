#!/bin/bash

/usr/local/spark/sbin/start-slave.sh spark://$1:7077 &&\
tail -f /usr/local/spark/logs/spark--org.apache.spark.deploy.worker.*.out
