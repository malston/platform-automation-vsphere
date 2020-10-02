# Provision a Tanzu Kubernetes Cluster

## Connect to the Supervisor Cluster as a vCenter Single Sign-On User

```sh
kubectl vsphere login --server=wcp.haas-423.pez.vmware.com --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify
```

### Check which namespace you are currently in (*)

```sh
kubectl config get-contexts
```

### Switch to the namespace we created

```sh
kubectl config use-context wcp.haas-423.pez.vmware.com
```

### Create a namespace

You have to do this from the Workload Management section in vCenter.

### Create the cluster

```sh
kubectl apply -f ./k8s/clusters/basic.yaml
```
