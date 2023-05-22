
# ------------------------------------------------------------------------------
#  PURPOSE:      THIS SCRIT WILL NAVIGATE THROUGH ALL THE AWS REGIONS AND ALL THE EKS CLUSTERS AVAILABLE IN THAT REGIONS AND GREP FOR THE AVAILABLE LOAD BALANCERS
#                THE lbS CAN BE OF TYPE CLASSIC, NETWORK AND APPLICATION
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
#!/bin/bash


aws ec2 describe-regions --all-regions --query "Regions[].{Name:RegionName}" --output text > all_regions.text
cat all_regions.text
echo "done"


# Will create file names with EKS clusters based on regions
while read -r region;
do
  REGION=$region
  echo $REGION
  echo "======"
  aws eks list-clusters --region $REGION --output text > clusters.text
  cat clusters.text
  if [[ -s clusters.text ]]; then
      echo "Now reading cluster.text"
      sed 's/^[ \t]*//;s/[ \t]*$//' < clusters.text
      sed 's/\CLUSTERS\b//g' clusters.text > a
      sed 's/^[ \t]*//;s/[ \t]*$//' < a > $REGION-cluster.text
      cat $REGION-cluster.text|wc -l
   else
      echo "The clusters.text is empty"
  fi


  #aws elbv2 describe-load-balancers --region $REGION|grep "DNSName" > DNS_NAME
  #sed 's/^[ \t]*//;s/[ \t]*$//' < DNS_NAME
  #sed 's/"DNSName": //g' DNS_NAME > a
  #sed 's/^[ \t]*//;s/[ \t]*$//' < a > $REGION-ELB.text
  #cat $REGION-ELB.text|wc -l


   echo "Starting"
   if [ -s $REGION-cluster.text ]; then
          #cat $REGION-cluster.text
          echo "<><><><><>"
          #if [ -s All_Cluster.ingress ]; then
                #rm All_Cluster.ingress
          #fi
          while read -r cluster;
          do
                  CLUSTER=$cluster
                  echo "************* $CLUSTER ****************"
                  echo "***************************************"
                  aws eks --region $REGION update-kubeconfig --name $CLUSTER
                  echo "current context is"
                  kubectl config current-context
                  #echo "NAMESPACE is "
                  #kubectl get ns

                  echo "List of ingress used in this $cluster is"
                  echo "$CLUSTER" >> All_Cluster.ingress
                  echo "===================================" >> All_Cluster.ingress

                  kubectl get ingress -A -o json|grep hostname | sed 's/.*"hostname": "//g' | sed 's/"//g'  >> All_Cluster.ingress
                  #cat All_Cluster.ingress
          done < $REGION-cluster.text
   else
          echo "$REGION-cluster.text is empty"
   fi

echo "done"
done < all_regions.text


while read -r region;
do
    echo "Reading all the load balancers in $region"
    aws elb  describe-load-balancers --region $region --output json |jq -r '.LoadBalancerDescriptions[] | select(.Instances==[]) | . as $l | [$l.DNSName] | @sh' | sed "s/'//g" >> all_elbs.text
    cat all_elbs.text|wc -l
    echo "<><<><><><><><><><><><><><><><><><><><><><><><><><><><>"
    aws elbv2 describe-load-balancers --region $region --output json |jq -r '.LoadBalancers[] | . as $l | [$l.DNSName] | @sh' | sed "s/'//g" >> all_elbs.text
    echo "Number of lines in this file is "
    cat all_elbs.text|wc -l


    #sed 's/^[ \t]*//;s/[ \t]*$//' < DNS_NAME
    #sed 's/"DNSName": //g' DNS_NAME > a
    #sed 's/^[ \t]*//;s/[ \t]*$//' < a >> all-ELB.text
    #cat $regions-ELB.text|wc -l
done < all_regions.text
