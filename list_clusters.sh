#!/bin/bash
#####################################################################################################
##########  
###########     This script will list all the EKS clusters in all the region in a specific AWS account

###########     Author - Ramya Murthy
#######################################################################################################

aws ec2 describe-regions --all-regions --query "Regions[].{Name:RegionName}" --output text > all_regions.text
cat all_regions.text

echo "done"



filename=cluster.text
if [ ! -f $filename ]
then
    touch $filename
fi




# Will create file names with EKS clusters based on regions
while read -r region;
do
  REGION=$region
  echo $REGION
  echo "======"
  aws eks list-clusters --region $REGION --output text > clusters.text
  #cat clusters.text
  if [[ -s clusters.text ]]; then
      sed 's/^[ \t]*//;s/[ \t]*$//' < clusters.text
      sed 's/\CLUSTERS\b//g' clusters.text > a
      echo $region >> cluster.text
      sed 's/^[ \t]*//;s/[ \t]*$//' < a >> cluster.text
      cat cluster.text|wc -l
   else
      echo "The clusters.text is empty"
  fi

done < all_regions.text
