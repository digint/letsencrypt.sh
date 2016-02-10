#!/bin/bash

#
# Deploy letsencrypt certificates via ssh.
#
# Use in conjunction with "ssh_filter_letsencrypt.sh".
#

set -e
set -u
set -o pipefail

declare -A rsh

### config section ###

rsh[example.org]="ssh -i /etc/ssh/id_rsa.letsencrypt letsencrypt@example.org"
rsh[www.example.org]="ssh -i /etc/ssh/id_rsa.letsencrypt letsencrypt@example.org"

### end config section ###


command=$1
domain=$2

if [[ -z "${domain}" ]]; then
    # clean_challenge is sometimes called with empty domain!
    echo " * ssh_hook.sh: ERROR: empty domain string! (command=${command})..." >&2
    exit 1
fi

echo " * ssh_hook.sh: ${command} for ${domain}..."

case $command in
  deploy_challenge|clean_challenge)
    ${rsh[$domain]} $@
    ;;
  deploy_cert)
    privkey=$3
    cert=$4
    fullchain=$5
    cat $privkey | ${rsh[$domain]} deploy_privkey $domain
    cat $cert | ${rsh[$domain]} deploy_cert $domain
    cat $fullchain | ${rsh[$domain]} deploy_fullchain $domain
    ;;
  *)
    echo "ssh_hook.sh: illegal command: ${command}" >&2
    exit 1
    ;;
esac

exit 0
