# blazingdb-automation
blazingdb-automation for blazingdb > 3.0

# Build docker

This process will build and zip all the artifacts and binaries into a single file called blazingsql.tar.gz

```shell-script
cd docker/blazingsql-build
nvidia-docker build -t demobuild .
nvidia-docker run --rm -v /path/blazingsql/src/:/home/builder/src/ -v /path/output/:/home/builder/output -v /home/user/.ssh/:/home/builder/.ssh/ demobuild
```

then check /path/output/ there will be the file blazingsql.tar.gz

# Demo
```shell-script
cd docker/blazingsql
cp /path/output/blazingsql.tar.gz .
nvidia-docker build -t demo .
nvidia-docker run --rm -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 demo

# inside the container
cd rapids && source activate gdf
# untar mortgage.tar.gz is optional 
tar -xzvf data/mortgage.tar.gz
bash utils/start_jupyter.s
```

You can mount your /tmp folder into the container  with -v /tmp:/tmp so this way you can use the from your host BlazingSQL and PyBlazing from the container.
Note: All the BlazingSQL stack is under supervisord
