#!/bin/bash

# This script retrieves the container image and task definition revision
# for a given cluster+service. If it can't retrieve it, assume
# this is the initial deployment and default to "not_found".
defaultImageTag='not_found'

# Exit if any of the intermediate steps fail
set -e

# Get parameters from stdin
eval "$(jq -r '@sh "role_arn=\(.role_arn) service=\(.service) cluster=\(.cluster) path_root=\(.path_root) account_id=\(.account_id) region=\(.region)"')"

# Assume the account role before executing the script
role_session_name="ecs-$service"
profile_name="ecs-$service"

temp_role=$(aws sts assume-role \
                    --role-arn $role_arn \
                    --role-session-name $role_session_name)

export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)
export AWS_REGION=$region

# Set AWS Config
{
  printf '\n%s\n' "[profile ${profile_name}]"
  printf '%s\n' "region = ${region}"
} >> "$AWS_CONFIG_FILE"

# Set AWS Credentials
{
  printf '\n%s\n' "[${profile_name}]"
  printf '%s\n' "aws_access_key_id = $AWS_ACCESS_KEY_ID"
  printf '%s\n' "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY"
  printf '%s\n' "aws_session_token = $AWS_SESSION_TOKEN"
} >> "$AWS_SHARED_CREDENTIALS_FILE"

# Remove extra quotes and backslashes from jsonencoding path_root in terraform
path_root="$(echo $path_root | sed -e 's/^"//' -e 's/"$//' -e 's/\\\\/\\/g')"

taskDefinitionID="$(aws ecs describe-services --service $service --cluster $cluster --region $region --profile $profile_name | jq -r 'if .failures[0].reason then .failures[0].reason else .services[0].taskDefinition end')"

# If a ECS Service is found, use the revision and image tag from it
if [[ ${taskDefinitionID:0:3} == 'arn' ]]; then {

  taskDefinitionRevision="$(echo "$taskDefinitionID" | sed 's/^.*://')"
  taskDefinition="$(aws ecs describe-task-definition --task-definition $taskDefinitionID --region $region --profile $profile_name)"
  containerImage="$(echo "$taskDefinition" | jq -r '.taskDefinition.containerDefinitions[0].image')"
  imageTag="$(echo "$containerImage" | awk -F':' '{print $2}')"
  jq -n --arg taskArn $taskDefinitionID --arg imageTag $imageTag --arg taskDefinitionRevision $taskDefinitionRevision '{task_arn: $taskArn, image_tag: $imageTag, task_definition_revision: $taskDefinitionRevision}'
  if [ $? -eq 0 ]; then
    exit 0
  else
    exit 1
  fi

} else {

  # No Service was found
  # Check if the provided service name could be a scheduled task on Amazon Cloudwatch Events
  if [[ "$taskDefinitionID" == "MISSING" ]]; then {
    hasEventRule="$(aws events list-rules --name-prefix $service --region $region --profile $profile_name | jq -r '.Rules' | jq length)"
    if [[ $hasEventRule -gt 0  ]]; then {
      jobTaskDefinitionID="$(aws events list-targets-by-rule --rule $service --region $region --profile $profile_name | jq -r '.Targets[0].EcsParameters.TaskDefinitionArn')"
      if [[ ${jobTaskDefinitionID:0:3} == 'arn' ]]; then {
        taskDefinitionRevision="$(echo "$jobTaskDefinitionID" | sed 's/^.*://')"
        taskDefinition="$(aws ecs describe-task-definition --task-definition $jobTaskDefinitionID --region $region --profile $profile_name)"
        containerImage="$(echo "$taskDefinition" | jq -r '.taskDefinition.containerDefinitions[0].image')"
        imageTag="$(echo "$containerImage" | awk -F':' '{print $2}')"
        jq -n --arg taskArn $jobTaskDefinitionID --arg imageTag $imageTag --arg taskDefinitionRevision $taskDefinitionRevision '{task_arn: $taskArn, image_tag: $imageTag, task_definition_revision: $taskDefinitionRevision}'
        if [ $? -eq 0 ]; then
          exit 0
        else
          exit 1
        fi
      }
      fi
    }
    fi
  }
  fi

  # No ECS Service or Clouwatch Event found.
  # Output default values to Terraform
  jq -n --arg task_arn "" \
        --arg imageTag "not_found" \
        --arg taskDefinitionRevision "0" \
        --arg region $region \
        --arg service $service \
        --arg cluster $cluster \
        --arg accountId $account_id \
        '{task_arn: $task_arn, image_tag: $imageTag, task_definition_revision: $taskDefinitionRevision, region: $region, service: $service, cluster: $cluster, accountId: $accountId}'
  
  # AWS config + credentials file cleanup
  tmp_aws_config="$(mktemp)"

  awk 'NF' "${AWS_CONFIG_FILE}" | sed -e '/^\['"$profile_name"'\]$/,/^\[/{//!d;}' -e '/^\['"$profile_name"'\]$/{d;}' \
      | sed -e '/^\[profile '"$profile_name"'\]$/,/^\[/{//!d;}' -e '/^\[profile '"$profile_name"'\]$/{d;}' > "$tmp_aws_config"
  mv "$tmp_aws_config" "${AWS_CONFIG_FILE}"

  awk 'NF' "${AWS_SHARED_CREDENTIALS_FILE}" \
      | sed -e '/^\['"$profile_name"'\]$/,/^\[/{//!d;}' -e '/^\['"$profile_name"'\]$/{d;}' > "$tmp_aws_config"
  mv "$tmp_aws_config" "${AWS_SHARED_CREDENTIALS_FILE}"

  unset AWS_PROFILE
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN

  exit 0
}
fi