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

    sed 's,!working_dir!,'"$working_dir"',g' update-cloudflare-dns.service |
    sed 's,!cf_zone_id!,'"$cf_zone_id"',g' |
    sed 's,!cf_record_id!,'"$cf_record_id"',g' |
    sed 's,!cf_auth_email!,'"$cf_auth_email"',g' |
    sed 's,!cf_dns_token!,'"$cf_dns_token"',g' |
    sed 's,!cf_domain!,'"$cf_domain"',g' > \
    /etc/systemd/user/update-cloudflare-dns.service

    cp update-cloudflare-dns.timer /etc/systemd/user/.

    systemctl --user daemon-reload
    systemctl --user start update-cloudflare-dns.service
}

install
