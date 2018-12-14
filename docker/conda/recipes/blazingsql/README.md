Create Environemnt:
```
$ conda env create -f environment.yml
$ source activate blazingsql_builder
```
Optional: create environment from zero
```
$ conda create blazingsql_builder
$ source activate blazingsql_builder
$ conda install anaconda-client conda-build
```

Build:
```
$ VERSION=0.1-dev BUILD=2 FILE_TAR=../blazingsql.tar.gz conda build . --output
```

Upload:
```
$ anaconda upload --user BlazingDB /path/to/file_0.tar.bz2 --label demo --label python35

```
