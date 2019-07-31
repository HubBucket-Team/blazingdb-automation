#!/bin/bash
# Usage: ./k8s_admin.sh status|delete|update|services

action=$1
echo "action: "$action

if [ "$action" == "status" ]; then
    echo "### scheduler ###"
    kubectl exec $(kubectl get pods|awk 'FNR == 2 {print $1}') supervisorctl status
    echo "### worker ###"
    kubectl exec $(kubectl get pods|awk 'FNR == 3 {print $1}') supervisorctl status
fi

if [ "$action" == "delete" ]; then
    kubectl delete pods --all
fi

if [ "$action" == "update" ]; then
    kubectl delete deployments --all
    kubectl apply -f k8s_blazingsql.yaml
fi

if [ "$action" == "services" ]; then
    kubectl get services
fi
