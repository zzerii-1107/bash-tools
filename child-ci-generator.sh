#!/bin/bash

while getopts ":t:" opt; do
    case $opt in
        t)
            tags=$OPTARG
        ;;
        \?)
            echo "ERR: Invalid option: -$OPTARG"
            exit 1
        ;;
        :)
            echo "ERR: Option -$OPTARG requires an argument"
            exit 1
        ;;
    esac
done

if [ -z $tags ]; then
    echo "ERR: Option -t required"
    exit 1
fi

subdiretory_list=$(find . -name terraform.tfvars | sed -e 's/\/terraform.tfvars//g' -e 's/\.\///g')

for i in $subdiretory_list; do
    cat <<EOF > $i/.gitlab-ci.yml
default:
  image:
    name: 이미지 정보 입력
    entrypoint:
      - '/usr/bin/env'
      - 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

.aws-configure: &aws-configure-profile
  - mkdir ~/.aws/
  - printf "[default]\\naws_access_key_id = %s\\naws_secret_access_key = %s\\n" "\${AWS_ACCESS_KEY_ID}" "\${AWS_SECRET_ACCESS_KEY}" > ~/.aws/credentials
  - printf "[default]\\nregion = %s\\noutput = json\\n" "\${AWS_DEFAULT_REGION}" > ~/.aws/config
  - export aws_credentials=\$(aws sts assume-role --role-arn \${ASSUME_ROLE_ARN} --role-session-name "test")
  - echo -e "[kcl]\\naws_access_key_id = \$(echo \$aws_credentials|jq '.Credentials.AccessKeyId'|tr -d '"')\\naws_secret_access_key = \$(echo \$aws_credentials|jq '.Credentials.SecretAccessKey'|tr -d '"')\\naws_session_token = \$(echo \$aws_credentials|jq '.Credentials.SessionToken'|tr -d '"')\\n" >> ~/.aws/credentials
  - echo -e "[profile kcl]\\nsource_profile = default\\nregion = \${AWS_DEFAULT_REGION}\\noutput = json\\nrole_arn = \${ASSUME_ROLE_ARN}" >> ~/.aws/config

.git-config-global: &git-config-global
  - git config --global url."https://oauth2:\${GITLAB_ACCESS_TOKEN}@\${GITLAB_URL}/".insteadOf "https://\${GITLAB_URL}"

.terraform-init: &terraform-init-module
  - cd \${TF_DIR}
  - terraform init -reconfigure -get=true -upgrade

.use-cache: &global_cache
  cache:
    - key: terraform
      paths:
        - \${TF_DIR}/.terraform
      policy: pull-push

variables:
  TF_DIR : "$i"
  TAGS   : "$tags"

stages:
  - refresh
  - validate
  - plan
  - apply
  - destroy-plan
  - destroy

.refresh:
  stage: refresh
  <<: *global_cache
  before_script:
    - *git-config-global
    - *terraform-init-module
  script:
    - terraform refresh
  when: manual
  allow_failure: false
  only:
    refs:
      - main
  tags:
    - \${TAGS}

validate:
  stage: validate
  <<: *global_cache
  before_script:
    - *git-config-global
    - *aws-configure-profile
    - *terraform-init-module
  script:
    - terraform validate
  only:
    refs:
      - main
  tags:
    - \${TAGS}

plan:
  stage: plan
  <<: *global_cache
  before_script:
    - *git-config-global
    - *terraform-init-module
  script:
    - terraform plan -refresh=false --out planfile
  dependencies:
    - validate
  artifacts:
    paths:
      - \${TF_DIR}/planfile
  only:
    refs:
      - main
  tags:
    - \${TAGS}

apply:
  stage: apply
  <<: *global_cache
  before_script:
    - *git-config-global
    - *terraform-init-module
  script:
    - terraform apply planfile
  dependencies:
    - plan
  when: manual
  allow_failure: false
  only:
    refs:
      - main
  tags:
    - \${TAGS}

.destroy-plan:
  stage: destroy-plan
  <<: *global_cache
  before_script:
    - *git-config-global
    - *terraform-init-module
  script:
    - terraform plan -destroy
  allow_failure: false
  only:
    refs:
      - main
  tags:
    - \${TAGS}

.destroy:
  stage: destroy
  <<: *global_cache
  before_script:
    - *git-config-global
    - *terraform-init-module
  script:
    - terraform destroy -auto-approve
  needs:
    - destroy-plan
  when: manual
  allow_failure: false
  only:
    refs:
      - main
  tags:
    - \${TAGS}
EOF
done
