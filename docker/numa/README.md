Run dask cluster with Docker:
```
$ ./start-dask-local.sh
$ open http://localhost:8787/workers
```


Run docker container as single node

```
$ ./main.sh
```

Run dask with vagrant
```
$ vagrant up
```

Set up a scheduler
```
$ vagrant ssh master
$ dask-scheduler --show
```

Set up the worker1
```
$ vagrant ssh worker1
$ dask-worker 192.168.2.10:8786
```

Set up the worker2
```
$ vagrant ssh worker2
$ dask-worker 192.168.2.10:8786
```

Test and check the dask cluster
```
$ ./while.sh
$ open http://192.168.2.10:9797/workers
```
