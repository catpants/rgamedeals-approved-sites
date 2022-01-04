#!/bin/bash
# Print a list of legit web storefronts for video games based on rgamedeals.net
# approved sites, formatted for a dyno.gg auto-delete filter
#
# 'pup' is from https://github.com/EricChiang/pup

SITE_WHITELIST=(
    'https://isthereanydeal.com'
    'https://steamdb.info'
    'https://gg.deals'
    'https://www.dekudeals.com'
    'https://psprices.com'
)

# Search 'icp-country-map' on
# https://www.amazon.ca/gp/navigation-country/select-country/
# for regional TLDs. gaming.amazon.com is added manually
AMAZON_URLS=(
    'https://gaming.amazon.com'
    'https://www.amazon.ae'
    'https://www.amazon.ca'
    'https://www.amazon.cn'
    'https://www.amazon.co.jp'
    'https://www.amazon.co.uk'
    'https://www.amazon.com'
    'https://www.amazon.com.au'
    'https://www.amazon.com.br'
    'https://www.amazon.com.mx'
    'https://www.amazon.com.tr'
    'https://www.amazon.de'
    'https://www.amazon.eg'
    'https://www.amazon.es'
    'https://www.amazon.fr'
    'https://www.amazon.in'
    'https://www.amazon.it'
    'https://www.amazon.nl'
    'https://www.amazon.pl'
    'https://www.amazon.sa'
    'https://www.amazon.se'
    'https://www.amazon.sg'
)

# Fetch a store page from rgamedeals.net and scrape the link to the store
# website, then print it to stdout
# $1: An rgamedeals.net store URL, e.g. "https://rgamedeals.net/store/y1odg"
function print_store_url() {
    STORE_URL=$(curl -s "${1}" | pup '.jumbotron > .lead > a attr{href}')
    [ -z "${STORE_URL}" ] && return

    # If www.amazon.com is approved, print the full list of amazon.com URLs instead
    if [ "${STORE_URL}" = "https://www.amazon.com" ]; then
        (IFS="|"; printf "|%s" "${AMAZON_URLS[*]}")
    else
        printf "|%s" "${STORE_URL}"
    fi
}

STORE_LINKS=$(curl -s "https://rgamedeals.net/" | pup '.store-approved attr{href}')
if [ -z "${STORE_LINKS}" ]; then
    echo "Couldn't get store links"
    exit 1
fi

(IFS="|"; printf "%s" "${SITE_WHITELIST[*]}")

for LINK in $STORE_LINKS; do
    if [[ "${LINK}" != /store/* ]]; then
        echo "Skipping invalid store link: '${LINK}'"
        continue
    fi

    print_store_url "https://rgamedeals.net${LINK}" &
done

wait
echo