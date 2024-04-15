#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

update_my_ip() {
  local now
  now=$(date -Iseconds)

  local current_ip
  current_ip=$(curl -s https://api.ipify.org)

  local file_name
  file_name=$(basename "$0")

  local log_file
  log_file="${UCF_PWD}/${file_name%.*}".log

  local last_ip
  touch "$log_file"
  last_ip=$(awk 'END{print $1}' "$log_file")

  if [[ "$current_ip" != "$last_ip" ]]; then
      echo "updating dns ip with $current_ip"
      curl -s --request PUT \
      --url "https://api.cloudflare.com/client/v4/zones/$(cat "$UCF_ZONE_ID")/dns_records/$(cat "$UCF_RECORD_ID")" \
      --header 'Content-Type: application/json' \
      --header "X-Auth-Email: $(cat "$UCF_AUTH_EMAIL")" \
      --header "Authorization: Bearer $(cat "$UCF_DNS_TOKEN")" \
      --data "$(printf '{
        "content": "%s",
        "name": "%s",
        "proxied": true,
        "type": "A",
        "comment": "Domain verification record",
        "ttl": 300
      }' "$current_ip" "$(cat "$UCF_DOMAIN")")"

    echo "$current_ip" "$now" >> "$log_file"
  else
    echo "same ip"
  fi
}

set -e
update_my_ip
