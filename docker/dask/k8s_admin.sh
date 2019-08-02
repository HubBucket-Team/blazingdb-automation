#!/bin/bash
# Usage: ./k8s_admin.sh action filter command
# Example: ./k8s_admin.sh cmd_pod|cmd_ip|status|delete|update|services scheduler|worker|10.32.4.5 ls /var/log/supervisor/

action=$1
filter=$2
shift
shift
cmd=$@

echo "action: "$action
echo "filter: "$filter
echo "cmd: "$cmd

if [ "$action" == "restart" ]; then
    echo "### orchestrator stop ###"
    kubectl get pods -l app=blazingdb-dask-scheduler -o custom-columns=NAME:.metadata.name --no-headers=true|xargs -I{} kubectl exec {} supervisorctl stop blazing-orchestrator
    echo "### ral stop ###"
    kubectl get pods -l app=blazingdb-dask-worker -o custom-columns=NAME:.metadata.name --no-headers=true|xargs -I{} kubectl exec {} supervisorctl stop blazing-ral
    echo "### orchestrator start ###"
    kubectl get pods -l app=blazingdb-dask-scheduler -o custom-columns=NAME:.metadata.name --no-headers=true|xargs -I{} kubectl exec {} supervisorctl start blazing-orchestrator
    echo "### ral start ###"
    kubectl get pods -l app=blazingdb-dask-worker -o custom-columns=NAME:.metadata.name --no-headers=true|xargs -I{} kubectl exec {} supervisorctl start blazing-ral
fi

if [ "$action" == "orchestrator_start" ]; then
    kubectl get pods -l app=blazingdb-dask-scheduler -o custom-columns=NAME:.metadata.name --no-headers=true|xargs -I{} kubectl exec {} supervisorctl start blazing-orchestrator
fi

if [ "$action" == "orchestrator_stop" ]; then
    kubectl get pods -l app=blazingdb-dask-scheduler -o custom-columns=NAME:.metadata.name --no-headers=true|xargs -I{} kubectl exec {} supervisorctl stop blazing-orchestrator
fi

if [ "$action" == "ral_start" ]; then
    kubectl get pods -l app=blazingdb-dask-worker -o custom-columns=NAME:.metadata.name --no-headers=true|xargs -I{} kubectl exec {} supervisorctl start blazing-ral
fi

if [ "$action" == "ral_stop" ]; then
    kubectl get pods -l app=blazingdb-dask-worker -o custom-columns=NAME:.metadata.name --no-headers=true|xargs -I{} kubectl exec {} supervisorctl stop blazing-ral
fi

if [ "$action" == "cmd_pod" ]; then
    kubectl get pods -l app=blazingdb-dask-$filter -o custom-columns=NAME:.metadata.name --no-headers=true|xargs -I{} kubectl exec {} $cmd
fi

if [ "$action" == "cmd_ip" ]; then
    kubectl get pods -o custom-columns=NAME:.metadata.name --field-selector=status.podIP=$filter --no-headers=true |xargs -I{} kubectl exec {} $cmd
fi

if [ "$action" == "status" ]; then
    kubectl get pods -l app=blazingdb-dask-$filter -o custom-columns=NAME:.metadata.name --no-headers=true|xargs -I{} kubectl exec {} supervisorctl status
fi

if [ "$action" == "delete" ]; then
    kubectl delete pods --all
fi

if [ "$action" == "update" ]; then
    kubectl delete deployments --all
    sleep 2
    kubectl apply -f k8s_blazingsql_scheduler.yaml
    sleep 10
    kubectl apply -f k8s_blazingsql_worker.yaml
fi

if [ "$action" == "services" ]; then
    kubectl get services
fi
