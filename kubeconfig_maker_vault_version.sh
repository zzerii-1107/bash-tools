#!/bin/bash

vault_id=$1

case $vault_id in
    kcl-prod)
        CLUSTER_LIST=(
        "prod-kcl1-cluster"
        "prod-kcl2-cluster"
        "prod-kcl3-cluster"
        "prod-kcl4-cluster"
        "prod-kcl5-cluster"
	    )
    ;;
    kcl-test)
        CLUSTER_LIST=(
		"test-kcl1-cluster"
        "test-kcl2-cluster"
        "test-kcl3-cluster"
        "test-kcl4-cluster"
        "test-kcl5-cluster"
	    )
    ;;
    kcl-dev)
        CLUSTER_LIST=(
		"dev-kcl1-cluster"
        "dev-kcl2-cluster"
        "dev-kcl3-cluster"
        "dev-kcl4-cluster"
        "dev-kcl5-cluster"
	    )
    ;;

esac
for CLUSTER in "${CLUSTER_LIST[@]}"; do
    aws-vault exec $vault_id --no-session -- aws eks update-kubeconfig --region ap-northeast-2 --name $CLUSTER
    cd
    mv .kube/config ~/.kube/$CLUSTER-config
    sed -i 's/command\: aws/command\: aws\-vault/g' .kube/$CLUSTER-config
done
