# Spark single master with two workers with Vagrant:

```
$ vagrant up
```

Start the master:
```
$ vagrant ssh master
vagrant@master$ ssh-keygen # generar sin passphrase
vagrant@master$ cat $HOME/.ssh/id_rsa.pub # Copiar contenido
vagrant@master$ exit

$ vagrant ssh worker1
vagrant@master$ nano .ssh/authorized_keys # Pegar el contenido y grabar
vagrant@master$ exit

$ vagrant ssh worker2
vagrant@master$ nano .ssh/authorized_keys # Pegar el contenido y grabar
vagrant@master$ exit

$ vagrant ssh master
vagrant@master$ /usr/local/spark/sbin/start-all.sh
```

Test the cluster:
```
$ vagrant ssh master
vagrant@master$ MASTER=spark://192.168.2.10:7077 /usr/local/spark/bin/run-example SparkPi
vagrant@master$ /usr/local/spark/bin/spark-submit --class DemoApp /tmp/demoapp/target/scala-2.11/demoproject_2.11-1.0.jar
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

# HDFS cluster single master with a workers:

```
$ vagrant up
```
Manual configuration:

STEP-00
```
#sudo nano /etc/sudoers
#add: hadoop  ALL=(ALL:ALL) ALL
#sudo su hadoop
#password: hadoop
```

STEP-01
```
#Master y slaves
#sudo nano /etc/hosts
MASTER
127.0.0.1	masterhdfs
127.0.0.1       localhost
192.168.100.101 hadoop-master
192.168.100.102 worker1hdfs
192.168.100.102 hadoop-slave1
SLAVE
127.0.0.1       localhost
192.168.100.102 worker1hdfs
192.168.100.101 hadoop-master
192.168.100.102 hadoop-slave1


#if there is:  127.0.0.1 hadoo-master in /etc/hosts in slave, drop it.
```

STEP-02
```
#Master
#ssh-keygen
#ssh-copy-id hadoop@hadoop-slave1
#ssh-copy-id hadoop@hadoop-master
#TEST Conectivity:
#ssh hadoop@hadoop-slave1
```



STEP-03:
```
#Añadir ips de workers into slaves file
#Master y slaves
#sudo nano /usr/local/hadoop/etc/hadoop/slaves
#hadoop-slave1
```

STEP-04
```
#In cloud this step is necesary
#port: open 54310 port ingress
```

STEP-05
```
#MASTER
# into: /usr/local/hadoop/etc/hadoop copy  two files hdfs-site.xml and core-site.xml (go directory hdfs_master/files to found them)
#SLAVE
# into: /usr/local/hadoop/etc/hadoop copy two files hdfs-site.xml and core-site.xml (go directory hdfs_slave/files to found them)
```

STEP-06
```
#in /usr/local/hadoop/sbin
#./start-all.sh
#./stop-all.sh\(optiona)
```

STEP-07
```
( Optional if ther is bugs)
#MASTER and SLAVE
#if permission denied: change the permissions:
#change permissions: sudo chown hadoop.hadoop -R /usr/local/hadoop/logs
#cambiar permisos a data directory : chown
```

STEP-08
```
sudo chown hadoop:hadoop -R current
```

OUTPUT
```
#jps
#MASTER
#Result
#jps
#27082 SecondaryNameNode
#27242 ResourceManager
#26859 NameNode
#27503 Jps

#WORKER
#23968 DataNode
#24306 Jps
```

STEP-08
```
#TEST
#MASTER
# cd /usr/local/hadoop/bin
# ./hdfs dfs -ls /.
#./hdfs dfs -mkdir /mortgage_2000
#./hdfs dfs -ls /.
#./hdfs dfs -copyFromLocal hola.txt /dirtest
#./hdfs dfs -ls /dirtest
#./hdfs dfs -cat /dirtest/hola.txt
#./hdfs dfs -copyFromLocal /home/hadoop/workspace/mortgage_2000/* /mortgage_2000


#WORKER
#cd data/
#ls current
#ls -R current/BP-384415771-127.0.0.1-1546981994598/current/
#cat current/BP-384415771-127.0.0.1-1546981994598/current/finalized/subdir0/subdir0/blk_1073741825
```
