#! /bin/sh

#Cluster Variables
namespace=conjur-ce
master_container_name=conjur-master
master_deployment_name=conjur-cluster
master_pod_name=$(kubectl -n $namespace get pods | grep $master_deployment_name | awk '{print $1;}')
master_service_name=conjur
master_service_url=http://$master_service_name.$namespace.svc.cluster.local

#CLI varilables
cli_container_name=conjur-cli
cli_deployment_name=$master_deployment_name
cli_pod_name=$(kubectl -n $namespace get pods | grep $cli_deployment_name | awk '{print $1;}')

#Account
default_account=conjur

#Generate API KEY
API_KEY=$(kubectl -n $namespace exec $master_pod_name -c $master_container_name -i -t conjurctl account create $default_account | awk '/admin:/{print $5}' | tr -d '\r\n')

cat > "conjurrc" <<EOF
---
account: $default_account
plugins: []
appliance_url: $master_service_url
EOF

kubectl cp conjurrc $namespace/$cli_pod_name:/root/.conjurrc -c $cli_container_name
rm conjurrc

kubectl -n $namespace exec $cli_pod_name -c $cli_container_name -i -t -- conjur authn login -u admin -p $API_KEY

kubectl cp policy $namespace/$cli_pod_name:/root/policy -c $cli_container_name
kubectl cp api_interaction $namespace/$cli_pod_name:/root/api_interaction -c $cli_container_name

kubectl -n $namespace exec $cli_pod_name -c $cli_container_name -i -t -- conjur policy load --replace root /root/policy/conjur.yaml
kubectl -n $namespace exec $cli_pod_name -c $cli_container_name -i -t -- conjur policy load db /root/policy/db.yaml | grep "api_key" | awk '{print $2;}' | sed -e 's/^"//' -e 's/"$//' > api_key 
kubectl -n $namespace exec $cli_pod_name -c $cli_container_name -i -t conjur variable values add db/password "thisISaPASSWORD"

kubectl cp api_key $namespace/$cli_pod_name:/root/policy/api_key -c $cli_container_name
rm api_key

kubectl -n $namespace exec -it $cli_pod_name -c $cli_container_name /bin/bash