#!/usr/bin/env bash
payload="{
    \"oldPassword\": \"$PT_old_password\",
    \"newPassword\": \"$PT_new_password\",
    \"confirmNew\": \"$PT_new_password\"
}"

cmd="/usr/bin/curl -X PUT -H 'Content-Type: application/json' -d '$payload' '$PT_uri://admin:$PT_old_password@localhost:$PT_port/api/user/password'"
eval "$cmd"
