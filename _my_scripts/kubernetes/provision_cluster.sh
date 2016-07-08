# list nodes here!


# go to kubernetes folder
cd ../../cluster/

export KUBERNETES_PROVIDER=ubuntu

#export KUBE_VERSION=1.1.8
export KUBE_VERSION=1.3.0
#export FLANNEL_VERSION=0.5.0
export FLANNEL_VERSION=0.5.5
#export ETCD_VERSION=2.2.0
export ETCD_VERSION=3.0.1

export role="ai i i"

export NUM_NODES=${NUM_NODES:-3}

export SERVICE_CLUSTER_IP_RANGE=192.168.3.0/24

export FLANNEL_NET=172.16.0.0/16

# install docker and bridge-utils on all nodes!
for n in $nodes
do
  echo "installing docker and bridge-utils on $n"
  ssh -oStrictHostKeyChecking=no root@$n "sudo apt-get update ; wget -qO- https://get.docker.com/ | sh ; sudo apt-get install bridge-utils"
done

./kube-up.sh

./deployAddons.sh