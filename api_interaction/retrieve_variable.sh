#! /bin/bash -e

function main(){
	echo "----"
	variable_pull
}

function variable_pull(){
	local CONJUR_APPLIANCE_URL=http://conjur.conjur-ce.svc.cluster.local
	local CONJUR_ACCOUNT=conjur
	#URL ENCODED ie alice@devops must be encoded as alice%40devops
	local CONJUR_AUTHN_LOGIN=secret-admin
	local CONJUR_AUTHN_API_KEY=$(cat /root/policy/api_key)
	
	printf "Generating Access Token using login name: $CONJUR_AUTHN_LOGIN\n"
	local access_token=$(curl -s -k -H "Content-Type: text/plain" -X POST --data "$CONJUR_AUTHN_API_KEY" --url $CONJUR_APPLIANCE_URL/authn/$CONJUR_ACCOUNT/$CONJUR_AUTHN_LOGIN/authenticate)
	printf "The access token is: \n"
	printf "$access_token\n\n"
	
	printf "Generating Authentication Token\n"
	local auth_token=$(echo -n $access_token | base64 | tr -d '\r\n')
	printf "The authentication token is:\n"
	printf "$auth_token\n\n"
	
	printf "Grabbing secret db/password\n"
	local secret=$(curl -s -k -X GET -H "Authorization: Token token=\"$auth_token\"" --url $CONJUR_APPLIANCE_URL/secrets/$CONJUR_ACCOUNT/variable/db/password)
	printf "The secret for db/password is:\n"
	printf "$secret\n\n"
}

main