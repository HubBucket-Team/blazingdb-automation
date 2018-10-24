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
nvidia-docker run --rm -ti -v /tmp/:/tmp -p 8888:8888 -p 8787:8787 -p 8786:8786 demo /bin/bash

# inside the container
cd rapids && source activate gdf
# untar mortgage.tar.gz is optional 
tar -xzvf data/mortgage.tar.gz
bash utils/start_jupyter.s
```
