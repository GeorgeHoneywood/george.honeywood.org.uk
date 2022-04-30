#!/usr/bin/env bash
set -e
# Usage: ./deploy.sh [--prod]

function check_links () {
    echo "checking links..."
    python3 get-links.py
    python3 check-links.py
}

OPTS_PROD=no

while [ "$1" != "" ]; do
    # not currently needed as no options have parameters 
    # param=$(echo "$1" | awk -F= '{print $1}')
    # value=$(echo $1 | awk -F= '{print $2}')
    param=$1

    case $param in
        --prod)
            OPTS_PROD=yes
            ;;
        *)
            ;;
    esac
    shift
done

echo "cleaning up..."
rm -rf public/
echo -n "deploying: "
if [[ $OPTS_PROD = "yes" ]]; then
    echo "production"
    hugo --gc --minify
    check_links

    rsync -avz --delete public/ honeyfox@git.honeyfox.uk:/var/www/html/george.honeywood.org.uk/
else
    SUB_DOMAIN="staging"
    if [[ $CI = "true" ]]; then
        # escape / characters in branch names
        SUB_DOMAIN="${GITHUB_REF_NAME//\//-}.staging"
    fi

    DOMAIN="$SUB_DOMAIN.george.honeywood.org.uk"
    URL="https://$DOMAIN"

    echo "staging deploy to $URL"
    hugo --gc --minify -D \
    --environment staging \
    -b "$URL"

    tar -C public -cvz . | \
    curl -v --oauth2-bearer "$SOURCEHUT_TOKEN" \
    -Fcontent=@- \
    "https://pages.sr.ht/publish/$DOMAIN"

    # for jq:
    #   -w '%{json}' -o /dev/null
    #   jq '{size: (.size_upload / 1000 / 1000 | tostring + " mb"), speed: (.speed_upload / 1000 | tostring + " kb/s"), upload_time: .time_total}'

    # slightly angry note: this is how to unpublish a site using gql
    # I would not wish this on my worst enemy
    # curl -H Authorization:"Bearer $SOURCEHUT_TOKEN" -H Content-Type:application/json -d '{"query": "mutation ($domain: String!) { unpublish(domain: $domain) {domain}}", "variables": {"domain": "george-honeywood.srht.site"}}' https://pages.sr.ht/query
fi
