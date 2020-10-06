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

Tanzu Kubernetes Grid Service provisions Tanzu Kubernetes clusters with the [PodSecurityPolicy Admission Controller](https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-kubernetes/GUID-CD033D1D-BAD2-41C4-A46F-647A560BAEAB.html) enabled. This means that pod security policy is required to deploy workloads.

Tanzu Kubernetes clusters include default `PodSecurityPolicy` that you can bind to for privileged and restricted workload deployment.

For `default` namespace:

```sh
kubectl create rolebinding rolebinding-default-privileged-sa-ns_default \
    --namespace=default --clusterrole=psp:vmware-system-privileged \
    --group=system:serviceaccounts
```

For cluster:

```sh
kubectl create clusterrolebinding clusterrolebinding-privileged-sa \
    --clusterrole=psp:vmware-system-privileged \
    --group=system:serviceaccounts
```

Then you can deploy the [Kubernetes Guestbook application](https://kubernetes.io/docs/tutorials/stateless-application/guestbook/).

### Harbor

To use Harbor as an internal registry, you'll need to configure the docker daemon on every worker to use an insecure registry or update the certs. See `add-harbor-cert-to-docker.sh` to update the certs and reboot the MacOS docker daemon. You can use the same script to update the Kubernetes nodes but you'll have to uncomment out some things first. Or you can login to every node and change the `/etc/docker/daemon.json` file like below:

```yaml
{
    "insecure-registries": ["10.213.249.66"],
    "exec-opts": ["native.cgroupdriver=systemd"],
    "bridge": "none",
    "log-driver": "json-file",
    "log-opts": {
       "max-size": "10m",
       "max-file": "3"
    }
}
```

where `10.213.249.66` is the IP of harbor.

Then run:

```sh
sudo systemctl restart docker
```

### Ingress

Follow these [instructions](https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-68AF0CE7-EA54-4D22-A3E6-0CEC2DF284C2.html?hWord=N4IghgNiBcIJYDsDmAnApgZwyAvkA).

1. Create the namespace for contour

    ```sh
    kubectl create namespace projectcontour
    ```

<!-- 1. Create role for the contour service account to be able to create privileged containers. The role references the `vmware-system-privileged` PSP.

    ```sh
    kubectl create -f k8s/contour/contour-role.yaml
    ```

1. Create a role binding for the contour service account

    ```sh
    kubectl create rolebinding contour-leaderelection \
        --namespace=projectcontour --role=contour-leaderelection \
        --serviceaccount=projectcontour:contour
    ```

    or

    ```sh
    cat <<EOF | kubectl apply -f -
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: RoleBinding
    metadata:
      name: contour-leaderelection
      namespace: projectcontour
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: contour-leaderelection
    subjects:
    - kind: ServiceAccount
      name: contour
      namespace: projectcontour
    EOF
    ``` -->

1. Deploy Contour

    ```sh
    kubectl apply -f k8s/contour/contour.yaml
    ```

1. Deploy test

    ```sh
    kubectl apply -f k8s/contour/ingress-test.yaml
    ```
