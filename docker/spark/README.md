Spark single master with two workers with Vagrant:
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

----------------------------------------------------------------


#STEP-00
#sudo su hadoop

#STEP-01
#Master
#ssh-keygen
#ssh-copy-id hadoop@hadoop-slave1

#STEP-02
#Master y slaves
#sudo nano /etc/hosts
#127.0.0.1	masterhdfs
#127.0.0.1       localhost
#192.168.100.101	masterhdfs
#192.168.100.101 hadoop-master
#192.168.100.102 hadoop-slave1

#STEP-03: Añadir ips de workers into slaves file
#Master y slaves
#sudo nano /usr/local/hadoop/etc/hadoop/slaves
#hadoop-slave1

#STEP-04: In cloud this step is necesary
#port: open 54310 port ingress


#STEP-05:
#MASTER
# into: /usr/local/hadoop/etc/hadoop copy 


# Start namenode manual (3)
# cd /usr/local/hadoop/sbin
#./hadoop-daemon.sh --script hdfs start namenode


#jps
#Result
#jps
#27082 SecondaryNameNode
#27242 ResourceManager
#26859 NameNode
#27503 Jps


#TEST
# cd /usr/local/hadoop/bin
# ./hdfs dfs -ls /.
#./hdfs dfs -mkdir /edith
#./hdfs dfs -ls /.
#./hdfs dfs -copyFromLocal hola.txt /edith
#./hdfs dfs -mkdir /edith
#./hdfs dfs -ls /edith
#./hdfs dfs -cat /edith/hola.txt



OJOO

cambiar permisos a log
ssh hadoop@hadoop-slave1


#ssh-keygen -t rsa
#ssh-copy-id hadoop@localhost
**no debe perir contrasña
ssh-copy-id hadoop@hadoop-master
ssh-copy-id hadoop@hadoop-masalve

start-all.sh

# master inciia a slave
copiarllaves
registrar slaves ( en master)
registrar 
etc/hosts ( en master)

#nano hdfs-site.xml ( cambiar a 1 replication)

borrar hadoo-master de /etc/hosts de slaves

stop all y satar-all


# sudo su hadoop, enter with user hadoop


