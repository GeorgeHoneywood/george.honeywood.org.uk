#!/usr/bin/env bash
set -e
# Usage: ./deploy.sh [--prod]

OPTS_PROD=no

while [ "$1" != "" ]; do
    param=$(echo $1 | awk -F= '{print $1}')
    value=$(echo $1 | awk -F= '{print $2}')

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
rm -r public/
echo -n "deploying: "
if [[ $OPTS_PROD = "yes" ]]; then
    echo "production"
    hugo --gc --minify
    rsync -avz --delete public/ honeyfox@git.honeyfox.uk:/var/www/html/george.honeywood.org.uk/
else
    echo "staging"
    hugo --gc --minify -D -b 'https://staging.george.honeywood.org.uk'

    tar -C public -cvz . | \
    curl -v --oauth2-bearer "$SOURCEHUT_TOKEN" \
    -Fcontent=@- 'https://pages.sr.ht/publish/staging.george.honeywood.org.uk'

    # slightly angry note: this is how to unpublish a site using gql
    # I would not wish this on my worst enemy
    # curl -H Authorization:"Bearer $SOURCEHUT_TOKEN" -H Content-Type:application/json -d '{"query": "mutation ($domain: String!) { unpublish(domain: $domain) {domain}}", "variables": {"domain": "george-honeywood.srht.site"}}' https://pages.sr.ht/query
fi
