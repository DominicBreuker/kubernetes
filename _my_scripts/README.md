# Operating Kubernetes

The scripts are in "_my_scripts/packet". I use packet as a exemplary simple hoster.

## Preparing cluster

Look into subfolder "packet". You will find scripts to bring up an exemplary cluster on packet.net.

### Bring up cluster

You will need an API token for packet.net to bring up the cluster.

```bash
export PACKET_AUTH_TOKEN=<your auth token>
export SSH_PASSPHRASE=<your ssh passphrase>
./prepare_machines.sh
```

During execution, you will be prompted for the passphrase. The script generates an SSH key to work on your machines. It also creates a packet.net project with 3 packet.net machines.

### Get cluster status

You can query for machine status with another script. It is important to get the IP's.

```bash
./machine_status.sh
```

### Teardown cluster

Destroy your machines with.

```bash
./teardown_machines.sh
```

This will destroy all machines, the project and the SSH key created with "./prepare_machines.sh". Note that this script just deletes your first SSH key and project found on packet.net. If you actually use packet to run things, don't execute the script ;)


### Get API options

On packet, you can configure your machines a bit. Execute the following scripts to discover the options.

```bash
./discover_api_options.sh
```

You can choose datacenter location, OS and machine size.


## Install Kubernetes

The scripts are in "_my_scripts/kubernetes"

### Run kube-up.sh

```bash
export nodes="147.75.202.113 147.75.202.75 147.75.202.41"
./provision_cluster.sh
```

This installs a basic kubernets cluster (single master, multi worker). Check the script for configuration.

The script first install docker and bridge-utils on all machines. Then, it uses Ubuntu install scripts provided by Kubernetes.

### Generate certificates

Certificates are used to secure cluster administration + cluster-internal communications.

```bash
export nodes="147.75.202.113 147.75.202.75 147.75.202.41"
export K8S_SERVICE_IP=192.168.3.1 # first IP from the cluster range (check provision_cluster.sh)
export MASTER_HOST=147.75.202.113 # IP of master - different config for multi master!
./generate_certificates.sh
```

The script generates a root CA and issues certificates for
- the API server
- all worker nodes (kubelet + kube-proxy)
- admin (kubectl tool)

The script also generates a pkcs12 to securely access kubernetes components through the browser. Note: the script will prompt for a password for this key. You must enter one. Remember it or you cannot use it in the browser.

Also note: the script will create kubeconfig-files with embedded certificates for simple configuration. It seems like "kubelet" can handle these while "kube-proxy" cannot. Check it out. If it does not work, change it to paths to the files (and use scp to get them onto the machines).

Also note: the script will use the "kubectl" binary placed in "./cluster/ubuntu/binaries", not the one installed on your machine. Use something like "cp $(which kubectl) ./cluster/ubuntu/binaries" to put your binary in place. Otherwise, the script may fail during the process.

### Get certificates onto servers


WIP!!!

```
export MASTER_HOST=147.75.202.113 # IP of master
export nodes="147.75.202.113 147.75.202.75 147.75.202.41"
./rollout_certificates.sh
```

Copy's certificates onto master and kubeconfig-files onto all worker nodes. Remember: you must configure the binaries to actually use these files!

How it works (exampele "kubelet", but applies to all binaries):
- Configuration for the binaries can be done in "/etc/default/kubelet"
- Logs are found in "/var/logs/upstart/kubelog.log"
- Restart can be done with "/etc/init.d/kubelet restart"