#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154
# ------------------------------------------------------------------------------
#  PURPOSE:      
# ------------------------------------------------------------------------------
#  PREREQS: a) 
#           b) 
#           c) 
#           d)
# ------------------------------------------------------------------------------
#  EXECUTE: 
# ------------------------------------------------------------------------------
#     TODO: 1) 
# ------------------------------------------------------------------------------
#   AUTHOR: Ramya Murthy
# ------------------------------------------------------------------------------
#  CREATED: 2021/10/
# ------------------------------------------------------------------------------
#set -x

# Script to push the ECR images to ECR REP on WT1

#!/bin/bash
source env-ecr

require_env() {
  if [[ -z "${!1}" ]]; then
    echo "Require Env.$1... Not Found"
    exit 1
  fi
  echo Require Env.$1... OK "(${!1})"
}

require_env AWS_ACCOUNT_ID_SRC
require_env AWS_ACCOUNT_ID_DST
require_env AWS_REGION_SRC
require_env AWS_REGION_DST
require_env TARGET_ENV
 
echo $src
echo $dst

echo $TARGET_ENV
TAG=$line-$TARGET_ENV
echo "TAG",$TAG


aws ecr get-login-password --region $AWS_REGION_DST | docker login --username AWS --password-stdin $dst

while read line
do
  echo "image" $line
  docker push $dst/$line-$TARGET_ENV
done < image_list.txt
aws s3 cp $TARGET_ENV.yaml s3://cicd-deploy-test/sc/$TARGET_ENV.yaml

