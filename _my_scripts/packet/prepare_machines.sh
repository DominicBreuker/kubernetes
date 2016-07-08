ENDPOINT=https://api.packet.net

KEY_FOLDER=../tmp/keys
# create ssh key
rm -rf $KEY_FOLDER
mkdir $KEY_FOLDER
ssh-keygen -t rsa -b 4096 -C "icke@example.com" -f $KEY_FOLDER/my_key -N "$SSH_PASSPHRASE"
SSH_KEY_ID=`echo $(curl -X POST --data "label=my_key" --data-urlencode "key@$KEY_FOLDER/my_key.pub" -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/ssh-keys" -s | jq '.id') | sed -e 's/^"//' -e 's/"$//'`

# add key locally
ssh-add $KEY_FOLDER/my_key
echo "created ssh key with ID $SSH_KEY_ID / added to local agent!"

# create project
PROJECT_ID=`echo $(curl --data "name=kubernetes" -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/projects" -s | jq '.id') | sed -e 's/^"//' -e 's/"$//'`
echo "created project with ID $PROJECT_ID"

# create devices
for i in `seq 1 3`;
do
  DEVICE_ID=`echo $(curl --data "hostname=node$i" --data "plan=baremetal_0" --data "billing_cycle=hourly" --data "facility=sjc1" --data "operating_system=ubuntu_14_04" -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/projects/$PROJECT_ID/devices" -s | jq '.id') | sed -e 's/^"//' -e 's/"$//'`
  echo "created device with ID $DEVICE_ID"
done


