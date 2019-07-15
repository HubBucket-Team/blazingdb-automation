#  How use Jenkins Agent

### Firt we need to create an agent
- Use the script new_agent.sh
```
cd docker/blazingsql-slave-jenkins
./new_agent.sh
```
-This script uses an image to generate another agent: blazingsql-slave-gpu-image ( It image is localted in blazingdb-jenkins project)
- After create the instance register the ip address like static into GCP