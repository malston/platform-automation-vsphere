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

You have to do this from the Workload Management section in vCenter. Make sure to set the storage class to `pacific-gold-storage-policy`.

### Create the cluster

```sh
kubectl apply -f ./k8s/clusters/basic.yaml
```

### Login

```sh
kubectl vsphere login --server=wcp.haas-423.pez.vmware.com \
    --tanzu-kubernetes-cluster-name tkg-cluster-1 \
    --tanzu-kubernetes-cluster-namespace ns1 \
    --vsphere-username administrator@vsphere.local \
    --insecure-skip-tls-verify
```

### Security

Tanzu Kubernetes Grid Service provisions Tanzu Kubernetes clusters with the PodSecurityPolicy Admission Controller enabled. This means that pod security policy is required to deploy workloads.

https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-kubernetes/GUID-CD033D1D-BAD2-41C4-A46F-647A560BAEAB.html

Tanzu Kubernetes clusters include default PodSecurityPolicy that you can bind to for privileged and restricted workload deployment.

```sh
kubectl create rolebinding rolebinding-default-privileged-sa-ns_default \
    --namespace=default --clusterrole=psp:vmware-system-privileged \
    --group=system:serviceaccounts
```

Then you can deploy the [Kubernetes Guestbook application](https://kubernetes.io/docs/tutorials/stateless-application/guestbook/).
