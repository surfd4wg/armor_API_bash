#!/bin/bash
# Authors:
#  Craig Ellrod, Joshua Seither
#  Armor Cloud Security
#
# Usage:
# ./armor_script_BASH_macos.sh “api_key” “api_secret_key”
#
# To call a different API endpoint, modify:
#  request_path="API-ENDPOINT", for example
#  request_path="/tickets/list"
#

apikey=$1
printf "\n API KEY: $apikey"

secret=$2
# don't print secret

authType="ARMOR-PSK"
printf "\n authType: $authType"

httpMethod="GET"
printf "\n Method: $httpMethod"

timestamp=$(date +%s)
printf "\n timestamp: $timestamp"

nonce=$(uuidgen)
printf "\n nonce: $nonce"

# Only the path portion of the url, no https, host, port, or query string values
requestPath="/core/avam"
requestBase="https://api.armor.com"
printf "\n requestPath: $requestPath"

# Empty string for GET
requestBody=""

requestData="${apikey}${httpMethod}${requestPath}${nonce}${timestamp}${requestBody}"
printf "\n requestData: $requestData"

# Build output filename, to later use as input into 'jq'
endPointFilename="${requestPath}.txt"
endPointOutputFilename=$(echo "$endPointFilename " | sed 's,/,_,g')
printf "\n OutputFilename: ${endPointOutputFilename}"

# openssl needs the binary option
# set line wrapping to 0 to force base64 output on one line
signature=$(echo -n "$requestData" | openssl dgst -sha512 -hmac "$secret" -binary | base64)
printf "\n Signature: $signature"

authHeaderValue="${authType} ${apikey}:${signature}:${nonce}:${timestamp}"
printf "\n authHeaderValue: $authHeaderValue \n"
echo '========================================================================'
echo ''

# Options are before the URL
curl -v \
     --location \
     -H "Authorization: ${authHeaderValue}" \
     -H 'Content-Type: application/json' \
     --request $httpMethod \
     "${requestBase}${requestPath}" \
     -o ${endPointOutputFilename}

# Output in readable JSON
cat $endPointOutputFilename | jq '.'