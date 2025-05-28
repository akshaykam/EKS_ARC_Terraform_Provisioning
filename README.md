--1.  This is repo do terraform provisioning for EKS cluster :
run following command from environment/prod/  
$  terraform init
$	terraform apply -target=module.eks

# check status of cluster 

$ aws eks describe-cluster --name eks-cluster-AK --region us-east-1 --query 'cluster.{Endpoint:endpoint,Name:name,Status:status}'

$	aws eks update-kubeconfig --name eks-cluster-AK --region us-east-1

$   kubectl get nodes
--2.  for Actions runner controller, do manual steps:

Helm is a package manager for Kubernetes that simplifies the deployment and management of complex applications. It is widely used to deploy applications, including the Actions Runner Controller, into EKS or any Kubernetes cluster.
Here’s why Helm is used for installing Actions Runner Controller:

$ helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
$ helm repo update
$ kubectl create namespace actions-runner-system
$ helm repo add jetstack https://charts.jetstack.io


$ helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.13.2 --set installCRDs=true
$ kubectl get pods -n cert-manager
$	helm install actions-runner-controller actions-runner-controller/actions-runner-controller --namespace actions-runner-system --set githubWebhookServer.enabled=false 

3. Create a GitHub Authentication Secret
You need a GitHub PAT (Personal Access Token).
Create Kubernetes secret:

$  kubectl create secret generic controller-manager  -n actions-runner-system 
  --from-literal=github_token=<YOUR_GITHUB_PAT>

kubectl create secret generic controller-manager -n actions-runner-system \--from-literal=github_token=<github_pat_>
________________________________________
4. Create a Runner Deployment (Custom Resource)
Create a file: runner-deployment.yaml

apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: example-runner-deployment
  namespace: actions-runner-system
spec:
  replicas: 5
  template:
    spec:
      repository: akshaykam/Self-hosted_Runner_OnEKS
✅ Explanation:
•	RunnerDeployment will automatically create one pod per runner.
•	replicas: 1 → one pod.
•	If you increase replicas, it will spawn 2/3/4 pods (each pod = 1 runner).

________________________________________
Apply:
kubectl apply -f runner-deployment.yaml
________________________________________

5. Verify
Check if runner pods are created:
$ kubectl get pods -n actions-runner-system

Check your GitHub repository → Settings → Actions → Runners → You will see the new runner registered!
 
________________________________________
6. Test GitHub Actions
Create .github/workflows/eks-runner-test.yml:
name: EKS + ARC Autoscaling

on:
  push:
  workflow_dispatch:

jobs:
  autoscale-test:
    name: "Autoscaling Test Job ${{ matrix.job }}"
    runs-on: [self-hosted]
    strategy:
      matrix:
        job: [1, 2, 3, 4, 5]
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Print Job Number
        run: echo "Running matrix job number ${{ matrix.job }}"
      - name: Simulate load
        run: |
          echo "Simulating workload on runner..."
          sleep $(( RANDOM % 30 + 30 ))  # Sleep 30–60 seconds to simulate load
It will automatically pick a runner pod, execute, and release it.
________________________________________
Summary:
Step	Action
1	Install actions-runner-controller
2	Create a GitHub PAT and Kubernetes secret
3	Deploy a RunnerDeployment CRD
4	Pod is automatically created
5	GitHub Actions run on Kubernetes pod
________________________________________
Important:
•	You can scale runners dynamically with HorizontalRunnerAutoscaler.
•	You can make runners ephemeral (1 job → destroy pod automatically).
•	You can attach AWS IAM roles if you want runners to access AWS.
________________________________________


Deregister/Delete actions-runner-controller from EKS

1.	Uninstall helm release:
$ 	helm uninstall actions-runner-controller -n actions-runner-system
•	Delete all Kubernetes resources created by the Helm release (Deployments, Services, CRDs, etc.).
•	Leave the namespace intact but empty.

2.	Delete custom Resource Definations (CRDs)

$	kubectl delete crd runners.actions.summerwind.dev runnerdeployments.actions.summerwind.dev

3.	Delete Namesapce (Optional)
$	kubectl delete namespace actions-runner-system

4.	Verify deletion:
$	kubectl get all -n actions-runner-system
$	kubectl get crd | grep actions.summerwind.dev

5.	Additional Cleanup (ConfigMaps, Secrets or Service Accounts)
kubectl delete all --all -n actions-runner-system

Check manually on AWS Console for all resources created.
