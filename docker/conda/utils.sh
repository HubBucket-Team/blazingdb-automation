
#!/bin/bash

#BUILD
WORKSPACE=$PWD


# BEFORE DEPLOY
#cd $WORKSPACE/

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh


output=$HOME/blazingsql/conda_output/
sudo chown 1000:1000 -R $output

echo "HOME/blazingsql/conda_output/ ====>>>> " $HOME/blazingsql/conda_output/


