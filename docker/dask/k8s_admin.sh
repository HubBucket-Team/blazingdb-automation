#!/bin/bash
# Usage: ./k8s_admin.sh status|delete|update|services build_number

action=$1
build_number=$2

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
    #kubectl --record deployment/blazingdb-dask-scheduler-dep set image blazingdb-dask-scheduler=blazingdb/blazingsql:dask_calcite_orchestrator_pyblazingv$build_number
    #kubectl --record deployment/blazingdb-dask-worker-dep set image blazingdb-dask-worker=blazingdb/blazingsql:dask_ral_pyblazingv$build_number
fi

if [ "$action" == "services" ]; then
    kubectl get services
fi
