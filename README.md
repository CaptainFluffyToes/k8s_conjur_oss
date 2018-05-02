# CyberArk Conjur Open Source Kubernetes Deployment
This will stand up a CyberArk Conjur Open Source cluster in Kubernetes.  

## Containers that comprise the cluster
* CyberArk Conjur Master
* Postgres Database
* CyberArk Conjur CLI

## Requirements
* Kubernetes v1.8 or higher
* Machine with kubectl configured with administrative privileges to the Kubernetes environment

## How to use

1. Clone Repo into machine with a configured kubectl
2. Run "kubectl apply -f CyberArkConjurOS.yml"
3. Check for the new Pod's readiness
4. Modify policies contained in the Policies folder to include new parameters if desired.  These policies will be automatically uploaded to Conjur.
5. Execute cluster_config.sh

You will be dropped at the CLI of the conjur CLI container which will allow you to use the script(s) in the api_interaction folder as well as communicate with conjur using the pre-installed and configured conjur cli components. 