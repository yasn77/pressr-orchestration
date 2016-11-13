#!/bin/bash

set -e
set -o pipefail

REQUIRED_ENV='AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID TF_VAR_db_password TF_VAR_access_key TF_VAR_secret_key TF_VAR_sshpubkey_file'
VALID_DEPLOYMENT_ENVS="development production"

usage() {
  cat <<EOF

The following environment variables need to be set:
$(echo "$REQUIRED_ENV" | tr ' ' '\n' | xargs -I {} echo -e \\t{})

Valid environments:
$(echo "$VALID_DEPLOYMENT_ENVS" | tr ' ' '\n' | xargs -I {} echo -e \\t{})

Valid app(s) that can be deployed:
$(for f in `ls ansible/*_deploy.yml`; do basename $f | cut -d '_' -f 1 | xargs -I {} echo -e \\t{}; done)

Usage: cloud-automation.sh <app> <environment> <num_servers> <server_size>

Note: <num_servers> is the number of instances to launch *per* availability zone
(currently configured to use 2 availability zones), so the actual instances
launched is <num_servers> * number_of_availability_zones

EOF
}

pre_flight_check() {
  we_have_a_problem=0

  [[ $# -ne 4 ]] && we_have_a_problem=1
  $(echo $VALID_DEPLOYMENT_ENVS | grep -q "$2") || we_have_a_problem=1
  [[ -f ./ansible/$1_deploy.yml ]] || we_have_a_problem=1


  for e in $REQUIRED_ENV
  do
    if [ -z "$(env | grep $e | cut -d'=' -f 2)" ]
    then
      we_have_a_problem=1
    fi
  done

  if [[ $we_have_a_problem -eq 1 ]]
  then
    usage
    exit 1
  fi
}

get_elb_dns() {
  DEPLOY_ENV=$1
  cd terraform
  echo "$(terraform output -state=${DEPLOY_ENV}/terraform.tfstate elb_dns_name)"
  cd - 1>/dev/null
}

launch_terraform() {
  DEPLOY_ENV=$1
  NUM_SERVERS=$2
  INSTANCE_SIZE=$3
  cd terraform
  terraform get $DEPLOY_ENV
  terraform plan \
    -var-file=${DEPLOY_ENV}.tfvars \
    -state=${DEPLOY_ENV}/terraform.tfstate \
    -var='instance_type="'${INSTANCE_SIZE}'"' \
    -var='app_instance_count="'${NUM_SERVERS}'"' \
    ${DEPLOY_ENV} &&
  terraform apply \
    -var-file=${DEPLOY_ENV}.tfvars \
    -state=${DEPLOY_ENV}/terraform.tfstate \
    -var='instance_type="'${INSTANCE_SIZE}'"' \
    -var='app_instance_count="'${NUM_SERVERS}'"' \
    ${DEPLOY_ENV}
  cd - 1>/dev/null
}

run_ansible() {
  APP=$1
  DEPLOY_ENV=$2
  ALL_OK=999
  CHECK_COUNT=0
  cd ansible
  set +e
  while [[ $CHECK_COUNT -lt 50 && $ALL_OK -ne 0 ]]
  do
    echo "Checking hosts have been provisioned..."
    ansible tag_env_${DEPLOY_ENV} --private-key $TF_VAR_sshpubkey_file  -i hosts/ec2.py -u ubuntu -m ping
    ALL_OK=$?
    ((CHECK_COUNT=CHECK_COUNT+1))
    sleep 5
  done
  if [[ $ALL_OK -ne 0 ]]
  then
    echo "Ansible failed to connect to 1 or more servers in ${CHECK_COUNT} attempts... Failing"
    exit 1
  fi
  set -e
  ansible-playbook --private-key $TF_VAR_sshpubkey_file  -i hosts/ec2.py -u ubuntu -e deployment_environment=${DEPLOY_ENV} main.yml
  ansible-playbook --private-key $TF_VAR_sshpubkey_file  -i hosts/ec2.py -u ubuntu -e deployment_environment=${DEPLOY_ENV} ${APP}_deploy.yml
  cd - 1>/dev/null
}

pre_flight_check $*
APP=$1
DEPLOY_ENV=$2
NUM_SERVERS=$3
INSTANCE_SIZE=$4
launch_terraform $DEPLOY_ENV $NUM_SERVERS $INSTANCE_SIZE
run_ansible $APP $DEPLOY_ENV

echo "All done, you should be able to browse to:"
echo "http://$(get_elb_dns $DEPLOY_ENV)"
