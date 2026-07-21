
# Generic

## Best Practises

* Private clusters
  * GPA for APIs
  * NAT for internet
  * Control Plane gets addtional Private Endpoint (no public IP)
* Authorized Networks
  * restrict access to Untrusted Actor the control plane to trusted CIDR ranges
  * Mandatory for private clusters
* Shilded Nodes
  * by default
* GKE Secrets
  * KMS to manage GKE KEK
* Bin Authorization
* Workload Identoty
* GKE Sandbox



* Tips
  * Compute Default SA has editor role so better use custom SA for cluster
* Properly handle PID 1, signal handling, and zombie processes [ [here](https://cloud.google.com/architecture/best-practices-for-building-containers?hl=en#signal-handling)]
  * launch your process with the `CMD` and/or `ENTRYPOINT`
* To protect your apps from attackers, try to **reduce the attack surface** of your app by removing any unnecessary tools
* Avoid running as root inside the container
* Launch the container in read-only mode - `readOnlyRootFilesystem`
* don't patch Containers in place for vulnerabilities - best practice is to rebuild the image, patches included, and redeploy it


## RBAC

* Secure your cluster by granting privileged operations (accessing secrets, for example) only to admin users.
* Enforce user-based authentication and authorization by the cluster.
* Limit resource creation (such as pods, persistent volumes, deployments) to specific namespaces.
* Have users and pods only see resources in their authorized namespace. This allows you to isolate resources
* within your organization (for example, between development teams).

!!! Note  

    IAM gives access at project level. RBAC can be used to give access at Cluster or Namespace level

## GKE Auth Networks [here](https://cloud.google.com/kubernetes-engine/docs/how-to/authorized-networks)

* provide an IP-based firewall that controls access to the GKE control plane
* The number of authorized network IP address ranges you can specify for public and private IP addresses depends on the type of cluster:

  * Public cluster: 50 IP address ranges
  * Private cluster: 100 IP address ranges
  * PSC-based clusters: 100 IP address ranges

```cli
gcloud container clusters create-auto CLUSTER_NAME \
    --enable-master-authorized-networks \
    --master-authorized-networks CIDR1,CIDR2,... \
    --no-enable-google-cloud-access
```

* Network Isolation benefits
  * private and public nodes in same cluster
  * restricted Control Plane access by restricting Google IPs or public IPs

* Isolate Control Plane with `--enable-private-endpoint`
* Isolate Node Pools with
  * Standard cluster with `--enable-private-nodes`
  * Autopilot cluster with `cloud.google.com/private-node=true`

* After making it private, if no NAT, external Connectivity may fail

## Autopilot [here](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)

* Google manages cluster config, scaling, security, upgrades
* Autopilot automatically provisions nodes backed by specialized machines, manages scheduling, and allocates hardware
  * Like, Hardware Accelerator for ML, ARM based compute for Mobile apps
* support using node selectors and node affinity to configure **workload separation**
* CLI command is `gcloud container clusters create-auto`
