#!/bin/bash

SITE_WHITELIST=(
    'https://isthereanydeal.com'
    'https://steamdb.info'
    'https://gg.deals'
    'https://www.dekudeals.com'
    'https://psprices.com'
)

# 'pup' is from https://github.com/EricChiang/pup
STORE_LINKS=$(curl -s "https://rgamedeals.net/" | pup '.store-approved attr{href}')
if [ -z "${STORE_LINKS}" ]; then
    echo "Couldn't get store links"
    exit 1
fi

(IFS="|"; printf "%s" "${SITE_WHITELIST[*]}")

function print_store_url() {
    STORE_URL=$(curl -s "https://rgamedeals.net${1}" | pup '.jumbotron > .lead > a attr{href}')
    [ -z "${STORE_URL}" ] && return
    printf "|%s" "${STORE_URL}"
}

for LINK in $STORE_LINKS; do
    if [[ "${LINK}" != /store/* ]]; then
        echo "Error: invalid store link: '${LINK}'"
        exit 1
    fi

    print_store_url $LINK &
done

wait
echo