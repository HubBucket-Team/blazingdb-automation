Compile docker images:

Copy tar file
```
$ cp ../../path/blazingsql-files.tar.gz ./blazingsql/
```

Run script:
```
$ ./docker_build_components.sh
```

Run containers:
```
$ docker-compose up
```

Execute bash inside container:
```
$ docker-compose exec ral1 bash
```

Note: Sometimes sockets still on /tmp volume. So, you need remove volume with follow command:
```
$ docker volume rm blazingsql_sockets
```


Run logging with Fluentd:
```
$ docker-compose -f docker-compose.fluentd.yml up
```
After that open http://localhost:9292 and put
user: admin
pass: changeme
Click on button "Setup fluentd", then click on "Create" button.
Finally click on "Start" button


Open Jupyter http://localhost and play.
