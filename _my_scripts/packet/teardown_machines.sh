ENDPOINT=https://api.packet.net

SSH_KEY_ID=`echo $(curl -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/ssh-keys" -s | jq '.ssh_keys[0].id') | sed -e 's/^"//' -e 's/"$//'`
PROJECT_ID=`echo $(curl -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/projects" -s | jq '.projects[0].id') | sed -e 's/^"//' -e 's/"$//'`
echo "working on project with ID $PROJECT_ID"

#DEVICE_ID=`echo $(curl -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/projects/$PROJECT_ID/devices" -s | jq '.devices[0].id') | sed -e 's/^"//' -e 's/"$//'`

DEVICES=$(curl -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/projects/$PROJECT_ID/devices" -s | jq '.devices|.[].id')
for DEVICE in $DEVICES
do
  ID=`echo $DEVICE | sed -e 's/^"//' -e 's/"$//'`
  curl -X DELETE -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/devices/$ID"
  echo "deleted device $ID"
done

#curl -X DELETE -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/devices/$DEVICE_ID"
#echo "deleted device $DEVICE_ID"

# delete project
curl -X DELETE -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/projects/$PROJECT_ID"
echo "deleted project $PROJECT_ID"

# delete ssh key
rm -rf keys
curl -X DELETE -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/ssh-keys/$SSH_KEY_ID"
echo "deleted ssh key $SSH_KEY_ID"


echo "done"