#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154
# ------------------------------------------------------------------------------
#  PURPOSE:       PULL ECR IMAGES from the AWS ACCOUNT recursively
# ------------------------------------------------------------------------------
#  PREREQS: a) 
#           b) 
#           c) 
#           d)
# ------------------------------------------------------------------------------
#  EXECUTE: scripts/get-creds.sh -v --env foo -z bar --project baz
# ------------------------------------------------------------------------------
#     TODO: 1) 
#           2) 
#           3) 
# ------------------------------------------------------------------------------
#   AUTHOR: Ramya Murthy
# ------------------------------------------------------------------------------
#  CREATED: 2021/10/00
# ------------------------------------------------------------------------------
#set -x


###-----------------------------------------------------------------------------
### VARIABLES
###-----------------------------------------------------------------------------


#!/bin/bash
#SOURCE ENVIRONMENT Variables
source env-ecr

:"$AWS_ACCOUNT_ID_SRC?        No Source Account ID defined}"
:"$AWS_REGION_SRC?            No Source region  defined}"
:"$TARGET_ENV?                No Target Environment specified}" 

echo $src
echo $dst


cp $HELM_PATH/composer-values.yaml $HELM_PATH/composer-values-$TARGET_ENV.yaml
sed -i -r "s#^(    registryIp: ).*#\1${dst//#/\\#}#"  composer-values-$TARGET_ENV.yaml



echo "Logging INTO SOURCE"
$(aws ecr get-login --no-include-email --region $AWS_REGION_SRC)
aws ecr get-login-password --region $AWS_REGION_SRC | docker login --username AWS --password-stdin $src
echo "LOGIN TO SOURCE SUCCESSFUl"




sed -n 's/^.*\([Ii]mage\)/\1/p' $HELM_PATH/composer-values.yaml > out.txt
sed 's/image://g' out.txt | sed -i '/imagePullPolicy:/d' a.txt |sed '/^$/d' a.txt > image_list.txt
sed -i -- 's/imageName: / /g' a.txt| sed -i -- 's/Image: / /g' image_list.txt


echo $TARGET_ENV
TAG=$line-$TARGET_ENV
echo "TAG",$TAG

while read line
do
  echo "image" $line
  echo "============"
  docker pull $src/$line
  docker tag $src/$line $dst/$line-$TARGET_ENV
  echo $line-$TARGET_ENV >> test.txt
  sed -i "s/$line/$line-$TARGET_ENV/" composer-values-$TARGET_ENV.yaml
done < image_list.txt


