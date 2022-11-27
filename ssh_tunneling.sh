#!/bin/bash

prod_ssh_key="/kcl/key/prod-ssh-key.pem"
test_ssh_key="/kcl/key/test-ssh-key.pem"
dev_ssh_key="/kcl/key/dev-ssh-key.pem"
test="/kcl/key/test.pem"
runner="/kcl/key/runner.pem"

default_port=6443
local_port=${2:-$default_port}

case $1 in
###########
# Chaelin
###########
  chaelin)
    endpoint=""
    bastion_host="1.2.3.4"
    ssh -i $test -L localhost:${local_port}:${endpoint}:443 ec2-user@$bastion_host
  ;;
###########
# ARGO
###########
  argo)
    endpoint=""
    bastion_host="1.2.3.4"
    ssh -i $test -L localhost:${local_port}:${endpoint}:443 ec2-user@$bastion_host
  ;;
###########
# RUNNER
###########
  runner)
    bastion_host="1.2.3.4"
    ssh -i $runner ec2-user@$bastion_host
  ;;
###########
# DEV
###########
  dev-kcl)
    endpoint=""
    bastion_host="1.2.3.4"
    ssh -i $dev_ssh_key -L localhost:${local_port}:${endpoint}:443 ec2-user@$bastion_host
  ;;
###########
# TEST
###########
  test-kcl1)
    endpoint=""
    bastion_host="1.2.3.4"
    ssh -i $test_ssh_key -L localhost:${local_port}:${endpoint}:443 ec2-user@$bastion_host
  ;;
  test-kcl2)
    endpoint=""
    bastion_host="1.2.3.4"
    ssh -i $test_ssh_key -L localhost:${local_port}:${endpoint}:443 ec2-user@$bastion_host
  ;;
esac

