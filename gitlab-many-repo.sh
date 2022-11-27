#!/bin/bash

project_names=(
    "test"
    "test02"
    "test03"
)

echo -n "Namespace ID를 입력하세요: "
stty -echo
read -r namespace_id
stty echo
echo

echo -n "gitlab personal access token 를 입력하세요: "
stty -echo
read -r token
stty echo

for project_name in "${project_names[@]}"; do
    echo
    echo "================================================="
    echo "Project Name: $project_name"
    echo "Namespace ID: $namespace_id"
    echo "================================================="
    echo

    curl -H "Content-Type:application/json" https:/github.com/api/v4/projects?private_token=$token -d "{ \"name\": \"$project_name\", \"namespace_id\": \"$namespace_id\"  }"

done


