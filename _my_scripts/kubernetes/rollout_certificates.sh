scp -r ./certificates root@$MASTER_HOST:/srv/kubernetes

for WORKER_IP in nodes
do
  # create worker node certificate
  echo "uploading to $WORKER_IP"
  scp ./certificates/node$WORKER_IP-kubeconfig.yml root@$WORKER_IP:/srv/kubernetes/worker_kubeconfig.yml
done
