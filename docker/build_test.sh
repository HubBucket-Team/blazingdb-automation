#!/bin/bash
# Usage: ral_branch

WORKSPACE=$PWD
GIT_BRANCH=$1

workspace=$HOME/blazingsql/workspace_ral/
output=$HOME/blazingsql/output_ral/
ssh_key=$HOME/.ssh_jenkins/
image_build="blazingsql/ral:test"

#mkdir -p /home/mario21ic/blazingsql/workspace_ral/blazingdb-ral_project/develop/
#ln -s ${WORKSPACE}/src_ral/ /home/mario21ic/blazingsql/workspace_ral/blazingdb-ral_project/develop/blazingdb-ral
#sudo chown 1000:1000 -R /home/mario21ic/blazingsql/workspace_ral/blazingdb-ral_project/

echo "GIT_BRANCH: $GIT_BRANCH"
BRANCH=${GIT_BRANCH/origin\//}
BRANCH="${BRANCH/\//\\/}"
echo "BRANCH: $BRANCH"

cp ./blazingsql-build/blazingsql-build.properties $workspace/
sed -ie "s/blazingdb_ral_branch.*/blazingdb_ral_branch\=$BRANCH/g" $workspace/blazingsql-build.properties
sed -ie "s/blazingdb_ral_tests.*/blazingdb_ral_tests\=true/g" $workspace/blazingsql-build.properties

cat $workspace/blazingsql-build.properties

cd $WORKSPACE/ral_test/

nvidia-docker build -t $image_build ./
if [ $? != 0 ]; then
  exit 1
fi

echo "nvidia-docker run --rm -e NEW_UID=$(id -u) -e NEW_GID=$(id -g) -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ $image_build"
nvidia-docker run --rm -e NEW_UID=$(id -u) -e NEW_GID=$(id -g) -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ $image_build
if [ $? != 0 ]; then
  exit 1
fi
