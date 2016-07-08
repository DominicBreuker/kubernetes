ENDPOINT=https://api.packet.net

echo "facilities"
echo $(curl -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/facilities" -s)
echo "..."

echo "operating-systems"
echo $(curl -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/operating-systems" -s)
echo "..."

echo "plans"
echo $(curl -H "X-Auth-Token: $PACKET_AUTH_TOKEN" "$ENDPOINT/plans" -s)
echo "..."