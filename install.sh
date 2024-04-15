#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

install() {
    local working_dir
    working_dir=$(pwd)

    echo "Insert the Cloudflare Zone ID:"
    cf_zone_id=$(systemd-ask-password -n | systemd-creds encrypt --name=cf_zone_id -p - - )

    echo "Insert the Cloudflare Record ID:"
    cf_record_id=$(systemd-ask-password -n | systemd-creds encrypt --name=cf_record_id -p - - )

    echo "Insert the Auth Email:"
    cf_auth_email=$(systemd-ask-password -n | systemd-creds encrypt --name=cf_auth_email -p - - )

    echo "Insert the Dns Token:"
    cf_dns_token=$(systemd-ask-password -n | systemd-creds encrypt --name=cf_dns_token -p - - )

    echo "Insert the Domain:"
    cf_domain=$(systemd-ask-password -n | systemd-creds encrypt --name=cf_domain -p - - )

    awk -v working_dir="$working_dir" '{sub(/!working_dir!/, working_dir); print}' update-cloudflare-dns.service |
    awk -v cf_zone_id="$cf_zone_id" '{sub(/!cf_zone_id!/, cf_zone_id); print}' |
    awk -v cf_record_id="$cf_record_id" '{sub(/!cf_record_id!/, cf_record_id); print}' |
    awk -v cf_auth_email="$cf_auth_email" '{sub(/!cf_auth_email!/, cf_auth_email); print}' |
    awk -v cf_dns_token="$cf_dns_token" '{sub(/!cf_dns_token!/, cf_dns_token); print}' |
    awk -v cf_domain="$cf_domain" '{sub(/!cf_domain!/, cf_domain); print}' > \
    /etc/systemd/system/update-cloudflare-dns.service

    cp update-cloudflare-dns.timer /etc/systemd/system/.

    systemctl daemon-reload
    systemctl start update-cloudflare-dns.service
}

install
