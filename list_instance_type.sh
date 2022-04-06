#!/bin/bash
###################################################################################################
#####     Ths script will list all the instace types available in all the regions in the aws account

####    AUTHOR - RAMYA MURTHY
#####################################################################################################

aws ec2 describe-regions --all-regions --query "Regions[].{Name:RegionName}" --output text > all_regions.text
cat all_regions.text


while read -r region; do
        echo "Now reading"  $region
        echo "===================="
        echo $region > Instance.text
        #aws ec2 describe-instances --region $region | grep InstanceType | sed 's/.*"InstanceType": "//g' | sed 's/"//g'| sed 's/,//g' >> Instance.text
        aws ec2 describe-instances --region $region --filters Name=instance-state-code,Values=16|grep InstanceType | sed 's/.*"InstanceType": "//g' | sed 's/"//g'| sed 's/,//g' >> Instance.text
        echo `cat  Instance.text|wc -l`
        sort Instance.text >> instance_used.text
done < all_regions.text


for word in `cat instance_used.text`; do echo $word; done |sort | uniq -c > final
sed 's/ \+/,/g' final > final.csv
