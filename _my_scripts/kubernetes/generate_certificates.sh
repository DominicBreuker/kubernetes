CERT_FOLDER=../tmp/certificates
TEMPLATE_FOLDER=../templates

rm -rf $CERT_FOLDER
mkdir $CERT_FOLDER
# create cluster root CA
openssl genrsa -out $CERT_FOLDER/ca-key.pem 2048
openssl req -x509 -new -nodes -key $CERT_FOLDER/ca-key.pem -days 10000 -out $CERT_FOLDER/ca.pem -subj "/CN=kube-ca"

# create API server certificates
openssl genrsa -out $CERT_FOLDER/apiserver-key.pem 2048
openssl req -new -key $CERT_FOLDER/apiserver-key.pem -out $CERT_FOLDER/apiserver.csr -subj "/CN=kube-apiserver" -config templates/openssl.cnf
openssl x509 -req -in $CERT_FOLDER/apiserver.csr -CA $CERT_FOLDER/ca.pem -CAkey $CERT_FOLDER/ca-key.pem -CAcreateserial -out $CERT_FOLDER/apiserver.pem -days 365 -extensions v3_req -extfile $TEMPLATE_FOLDER/openssl.cnf

for WORKER_IP in $nodes
do
  # create worker node certificate
  echo "generating certs for $WORKER_IP"
  WORKER_FQDN="node$WORKER_IP"
  openssl genrsa -out $CERT_FOLDER/$WORKER_FQDN-worker-key.pem 2048
  WORKER_IP=$WORKER_IP openssl req -new -key $CERT_FOLDER/$WORKER_FQDN-worker-key.pem -out $CERT_FOLDER/$WORKER_FQDN-worker.csr -subj "/CN=$WORKER_FQDN" -config $TEMPLATE_FOLDER/worker-openssl.cnf
  WORKER_IP=$WORKER_IP openssl x509 -req -in $CERT_FOLDER/$WORKER_FQDN-worker.csr -CA $CERT_FOLDER/ca.pem -CAkey $CERT_FOLDER/ca-key.pem -CAcreateserial -out $CERT_FOLDER/$WORKER_FQDN-worker.pem -days 365 -extensions v3_req -extfile $TEMPLATE_FOLDER/worker-openssl.cnf
  export CA_CERT_BASE64=$(cat $CERT_FOLDER/ca.pem | base64)
  export WORKER_CERT_BASE64=$(cat $CERT_FOLDER/$WORKER_FQDN-worker.pem | base64)
  export WORKER_KEY_BASE64=$(cat $CERT_FOLDER/$WORKER_FQDN-worker-key.pem | base64)
  perl -p -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $TEMPLATE_FOLDER/worker-kubeconfig.yml &> $CERT_FOLDER/$WORKER_FQDN-kubeconfig.yml
done

# create admin certificates
openssl genrsa -out $CERT_FOLDER/admin-key.pem 2048
openssl req -new -key $CERT_FOLDER/admin-key.pem -out $CERT_FOLDER/admin.csr -subj "/CN=kube-admin"
openssl x509 -req -in $CERT_FOLDER/admin.csr -CA $CERT_FOLDER/ca.pem -CAkey $CERT_FOLDER/ca-key.pem -CAcreateserial -out $CERT_FOLDER/admin.pem -days 365


# create a certifcicate for the browser (requires password!)
openssl pkcs12 -export -clcerts -inkey $CERT_FOLDER/admin-key.pem -in $CERT_FOLDER/admin.pem -out $CERT_FOLDER/kubecfg.p12 -name "kubecfg"


#perl -p -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < templates/openssl.cnf &> certificates/openssl.cnf