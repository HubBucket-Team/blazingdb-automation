Spark single master with two workers with Vagrant:
```
$ vagrant up

$ vagrant ssh master
vagrant@master$ sudo apt-get install -y python
vagrant@master$ exit

$ vagrant up --provision
```

Start the master:
```
$ vagrant ssh master
vagrant@master$ /usr/local/spark/bin/spark-class org.apache.spark.deploy.master.Master
```

Start the workers:
```
$ vagrant ssh worker1
vagrant@master$ /usr/local/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://<private_ip_master>:7077/

$ vagrant ssh worker2
vagrant@master$ /usr/local/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://<private_ip_master>:7077/
```

Test the cluster:
```
$ vagrant ssh master
vagrant@master$ /usr/local/spark/bin/run-example SparkPi
```


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

HDFS cluster single master with a workers:
```
$ vagrant up
```

SSH Conecction
```
$ ssh -o PubkeyAuthentication=no vagrant@192.168.100.101
$ ssh -o PubkeyAuthentication=no vagrant@192.168.100.102
```

En master
```
ssh-keygen
ssh-copy-id vagrant@192.168.100.102
```

```

# Before: (1)
En /etc/hosts
127.0.0.1 localhost
10.138.0.2 hadoop-master

#slaves (2): Añadir ips de workers en slaves file in master
sudo nano /usr/local/hadoop/etc/hadoop/slaves
10.138.0.3
10.138.0.4

#port: open 54310 port ingress
sudo ufw allow 54310/tcp
# test
sudo netstat -tulpn


# Start namenode manual (3)
# cd /usr/local/hadoop/sbin
#./hadoop-daemon.sh --script hdfs start namenode
#jps
 
#TEST
# cd /usr/local/hadoop/bin
# ./hdfs dfs -ls /.
#./hdfs dfs -mkdir /edith
#./hdfs dfs -ls /.
```
