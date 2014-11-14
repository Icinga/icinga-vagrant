#!/bin/bash
 
sleep 3
 
IP_ADDRESS=$(hostname  -I | cut -f1 -d' ')
GRAYLOG2_URL="http://admin:admin@${IP_ADDRESS}:12900"
 
GRAYLOG2_INPUT_GELF_TCP='
{
      "global": "true",
      "title": "Gelf TCP",
      "configuration": {
        "port": 12201,
        "bind_address": "0.0.0.0"
      },
      "creator_user_id": "admin",
      "type": "org.graylog2.inputs.gelf.tcp.GELFTCPInput"
}'
 
GRAYLOG2_INPUT_GELF_UDP='
{
      "global": "true",
      "title": "Gelf UDP",
      "configuration": {
        "port": 12201,
        "bind_address": "0.0.0.0"
      },
      "creator_user_id": "admin",
      "type": "org.graylog2.inputs.gelf.udp.GELFUDPInput"
}'
 
GRAYLOG2_STREAM_CATCH_ALL='
{
        "title": "Catch all",
        "description": "All messages",
        "creator_user_id": "admin",
        "rules": [{
                "field": "message",
                "value": ".*",
                "type": 2,
                "inverted": false}]
}'
 
GRAYLOG2_STREAM_ALERT='
{
        "parameters": {
                "grace": 10,
                "time": 5,
                "backlog": 0,
                "threshold_type": "more",
                "threshold": 3
        },
        "creator_user_id": "admin",
        "type": "message_count"
}'
 
INPUTS=$(curl -X GET -H "Content-Type: application/json" ${GRAYLOG2_URL}/system/inputs 2>/dev/null)
STREAMS=$(curl -X GET -H "Content-Type: application/json" ${GRAYLOG2_URL}/streams 2>/dev/null)
 
if [ $(echo $INPUTS | grep -c "GELF TCP") != "1" ]; then
        curl -v -X POST -H "Content-Type: application/json" -d "${GRAYLOG2_INPUT_GELF_TCP}" ${GRAYLOG2_URL}/system/inputs > /dev/null
fi
 
if [ $(echo $INPUTS | grep -c "GELF UDP") != "1" ]; then
        curl -v -X POST -H "Content-Type: application/json" -d "${GRAYLOG2_INPUT_GELF_UDP}" ${GRAYLOG2_URL}/system/inputs > /dev/null
fi
 
if [ $(echo $STREAMS| grep -c "Catch all") != "1" ]; then
        curl -v -X POST -H "Content-Type: application/json" -d "${GRAYLOG2_STREAM_CATCH_ALL}" ${GRAYLOG2_URL}/streams > /dev/null
        STREAMID=$(curl -s -X GET -H "Content-Type: application/json" ${GRAYLOG2_URL}/streams | ruby -rjson -e 'api=JSON.parse(STDIN.read);api["streams"].each{|stream| puts stream["id"] if stream["title"] == "Catch all"}')
        curl -v -X POST -H "Content-Type: application/json" ${GRAYLOG2_URL}/streams/${STREAMID}/resume > /dev/null
        curl -v -X POST -H "Content-Type: application/json" -d "${GRAYLOG2_STREAM_ALERT}" ${GRAYLOG2_URL}/streams/${STREAMID}/alerts/conditions > /dev/null
fi
 
exit 0
