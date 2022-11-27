#!/bin/bash

echo -n "Project의 이름을 입력하세요: "
stty -echo
read -r project_name
stty echo
echo

echo -n "Namespace ID를 입력하세요: "
stty -echo
read -r namespace_id
stty echo
echo

echo -n "gitlab personal access token 를 입력하세요: "
stty -echo
read -r token
stty echo

echo
echo "================================================="
echo "Project Name: $project_name"
echo "Namespace ID: $namespace_id"
echo "================================================="
echo
echo -n "위의 정보가 맞습니까?(y/n) "
read yn

if [[ $yn != "y" ]];then
    echo "종료합니다."
    exit
fi

curl -H "Content-Type:application/json" https://github.com/api/v4/projects?private_token=$token -d "{ \"name\": \"$project_name\", \"namespace_id\": \"$namespace_id\"  }"

