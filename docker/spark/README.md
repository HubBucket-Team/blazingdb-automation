Spark single master with two workers with Vagrant:
```
$ vagrant up
```

Start the master:
```
$ vagrant ssh master
vagrant@master$ /usr/local/spark/bin/spark-class org.apache.spark.deploy.master.Master -h 192.168.2.10
```

Start the workers:
```
$ vagrant ssh worker1
vagrant@master$ /usr/local/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://192.168.2.10:7077

$ vagrant ssh worker2
vagrant@master$ /usr/local/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://192.168.2.10:7077
```

Test the cluster:
```
$ vagrant ssh master
vagrant@master$ MASTER=spark://192.168.2.10:7077 /usr/local/spark/bin/run-example SparkPi
```
Open in your browser: http://192.168.2.10:8080/


DEPRECATED
Spark single master with two workers with Docker:

Build docker image:
```
packer build -only=docker template.json
```

Build the docker image and run
```
$ docker-compose build master
$ docker-compose up -d
```

Open in your browser http://localhost/8080


Playing with spark-shell
```
$ docker-compose exec master bash
# spark-shell
> val broadcastAList = sc.broadcast(List("a", "b", "c", "d", "e"))
> sc.parallelize(List("1", "2", "3")).map(x => broadcastAList.value ++x).collect
```

Open in your browser http://localhost:4040

Playing with examples
```
$ docker-compose exec master bash
# /usr/local/spark/bin/run-example SparkPi
```

