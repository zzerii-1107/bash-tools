#!/bin/bash

AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_DEFAULT_REGION="ap-northeast-2"
ASSUME_ROLE_ARN="arn"

mkdir -p ~/.aws/
printf "[default]\naws_access_key_id = %s\naws_secret_access_key = %s\n" "${AWS_ACCESS_KEY_ID}" "${AWS_SECRET_ACCESS_KEY}" > ~/.aws/credentials
aws_credentials=$(aws sts assume-role --role-arn ${ASSUME_ROLE_ARN} --role-session-name "test")
echo -e "[kcl]\naws_access_key_id = $(echo $aws_credentials|jq '.Credentials.AccessKeyId'|tr -d '"')\naws_secret_access_key = $(echo $aws_credentials|jq '.Credentials.SecretAccessKey'|tr -d '"')\naws_session_token = $(echo $aws_credentials|jq '.Credentials.SessionToken'|tr -d '"')\n" >> ~/.aws/credentials
echo -e "[profile kcl]\nsource_profile = default\nregion = ${AWS_DEFAULT_REGION}\noutput = json\nrole_arn = ${ASSUME_ROLE_ARN}" >> ~/.aws/config
