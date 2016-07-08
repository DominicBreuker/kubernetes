ENDPOINT=https://api.packet.net

# get project
PROJECT_ID=`echo $(curl -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/projects" -s | jq '.projects[0].id') | sed -e 's/^"//' -e 's/"$//'`
echo "Reading status of project $PROJECT_ID"

# list devices with status
DEVICES=$(curl -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/projects/$PROJECT_ID/devices" -s | jq '.devices')

echo "Node IDs"
echo $(echo $DEVICES | jq '.[].id')
echo "Node names"
echo $(echo $DEVICES | jq '.[].hostname')
echo "Node status"
echo $(echo $DEVICES | jq '.[].state')
echo "Node IP's"
echo $(echo $DEVICES | jq '.[].ip_addresses|.[0].address')