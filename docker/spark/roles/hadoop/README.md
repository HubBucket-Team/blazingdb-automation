
## **HADOOP ANSIBLE PROJECT**
This project install hadoop in master and in workers.

Have two roles in playbook.yml:

    - master
    - worker

When we need to install hadoop in master server use only the "master" role, the same when we need install hadoop in a worker.

**Before launch this playbook do this steps:**
- Create the infrastucture to the virtual machine and get its ips.
- Modified this files in the virtual machines:

    **In master server:**
    - Add in file /etc/hosts the private ip and dns to master
        ```
        127.0.0.1 localhost
        10.138.0.2 hadoop-master
        ```
    - In file /usr/local/hadoop/etc/hadoop/slaves add the private ips from workers
        ```
        10.138.0.3
        10.138.0.4
        ```
    **In worker servers**
    - Add in file /etc/hosts the private ip and dns to master
        ```
        127.0.0.1 localhost
        10.138.0.2 hadoop-master
        ```

**To launch the playbook:**

- Make sure put the correct ip into file "hosts", it depends  role to execute.
- Set the role is in playbook.yml
- To install hdfs execute the playbook:
    ```
    ansible-playbook -i hosts -s -k -u edith playbook.yml
    ```
**After execute the playbook, up hdfs:**

**In master server**
- Start namenode in master:

    ```
    cd /usr/local/hadoop/sbin
    ./hadoop-daemon.sh --script hdfs start namenode
    test:
    jps
    namenode is unable
    ```
**In worker servers**
- Start datanode in workers:

    ```
    cd /usr/local/hadoop/sbin
    ./hadoop-daemons.sh --script hdfs start datanode
    test:
    jps
    datanode is unable
    ```

**To test the orchestation hdfs cluster, try this:**
    
**In master server**
- List the hdfs files and create a "test" directory

    ```
    cd /usr/local/hadoop/bin
    ./hdfs dfs -ls /.
    ./hdfs dfs -mkdir /test
    ./hdfs dfs -ls /.
    ```