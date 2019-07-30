# Docker Compose 

# Copy tar into blazingsql directory
cp blazingsql-files.tar.gz  ..blazingdb-automation/docker/blazingsql

# Execute build components
./docker_build_components.sh
cd ral_orchestrator
docker-compose build -t blazingdb/blazingsql:ral_orchestrator_tcp .

# Exeute docker compose
docker-compose -f docker-compose.tcp.yml up -d
# ** To stop docker compose services
docker-compose down

# To se the docker-compse componentes
docker-compose ps

# Then go to localhost:80
# In the  first demo is necesary add the conexiónwith orchestrator
pyblazing.SetupOrchestratorConnection('172.21.1.3', 8889)

#  Kubernetes
# For create the cluster go to the job:  http://35.211.56.200:8080/view/BLAZINGSQL/job/07.BLAZINGDB_CREATE%20_CLUSTER_GKE/

