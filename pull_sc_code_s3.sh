########################################
#######################################
# 1. Pull Code from S3
# 2. Run Auutomated script
# 3. Upload the results to s3
###########################################
##########################################
source env_variables

require_env() {
  if [[ -z "${!1}" ]]; then
    echo "Require Env.$1... Not Found"
    exit 1
  fi
  echo Require Env.$1... OK "(${!1})"
}



#BUCKET_NAME="ibm-dish-sourcecode"
#TEST_DATA_BUCKET="ibm-dish-sourcecode"



#CURRENT_PATH=`pwd`
#CODE_REPO_NAME="COMPOSER-Release-0.22.13"

require_env AWS_ACCESS_KEY_ID
require_env AWS_SECRET_ACCESS_KEY
require_env AWS_SESSION_TOKEN



function s3_bucket_check {
      S3_BUCKET_NAME=$1
      echo $S3_BUCKET_NAME
      S3_CHECK=$(aws s3 ls "s3://${S3_BUCKET_NAME}" 2>&1)
      if [ $? != 0 ]
      then
        NO_BUCKET_CHECK=$(echo $S3_CHECK | grep -c 'NoSuchBucket')
        if [ $NO_BUCKET_CHECK = 1 ]; then
                echo "Bucket does not exist"
                exit 0
        fi

      else
           echo "Bucket Exists - " $S3_BUCKET_NAME
      fi
}


echo $BUCKET_NAME
echo $TEST_DATA_BUCKET
echo $RESULTS_BUCKE
echo "*********************************"

s3_bucket_check $BUCKET_NAME
s3_bucket_check $TEST_DATA_BUCKET
s3_bucket_check $RESULTS_BUCKET

while true; do
     echo  -e "Enter the action to be performed. \n USAGE: \n a - To Pull the code only \n b - To Copy test data excel file from S3 \n c - To Run Automated Test \n d - To view depenedency results file  \n e. Upload Results/Logs/Jsons to S3 \n f. To Exit"
     echo "<><><><>><><><><><><><><><><><><><><><><><><><><><><><><>"

     read -p 'Enter action to be performed : ' 'user_action'
     echo $user_action


     if [[ $user_action == "a" ]]; then
             read -p 'Enter the Test Automation Code Repo name : ' 'CODE_REPO_NAME'
             echo $CODE_REPO_NAME
             aws s3 cp s3://${BUCKET_NAME}/$CODE_REPO_NAME ./
             tar -xvf  $CODE_REPO_NAME.tar
             echo "Code download is completed"

     elif [[ $user_action == "b" ]];then
             read -p 'Enter the file name to be copied: ' 'DATA_FILE'
             echo $DATA_FILE
             #aws s3 ls s3://$TEST_DATA_BUCKET
             TEST_DATA_PATH=${CODE_REPO_NAME}/TestAutomation/TestData/${EKS_ENV_NAME}

             aws s3 cp s3://$TEST_DATA_BUCKET/$DATA_FILE ${CURRENT_PATH}/${TEST_DATA_PATH}
             echo "Download complete \n"


     elif [[ $user_action == "c" ]]; then
             #read -p 'Enter the code repo release : ' 'CODE_REPO_NAME'
             read -p 'Enter the file name for test execution : ' 'DATA_FILE'
             echo $CODE_REPO_NAME
             echo ${DATA_FILE}
             TEST_DATA_PATH=${CODE_REPO_NAME}/TestAutomation/TestData/${EKS_ENV_NAME}
             TEST_DATA_FILE=${CURRENT_PATH}/${TEST_DATA_PATH}/${DATA_FILE}
             echo $TEST_DATA_FILE
             ls $TEST_DATA_PATH
             if [[ -d "$TEST_DATA_FILE" ]]; then
                     echo file does not exist in $TEST_DATA_PATH
                     echo "The specified file doees not exist in path. Download and rerun the tests"
             else
                     echo "file exists in" $TEST_DATA_PATH
                     cd ${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/
                     python3 main_csv.py $TEST_DATA_FILE
             fi


     elif [[ $user_action == "d" ]]; then
             cd ${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/
             dependency_file=`ls ${CURRENT_PATH}/${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/dependency* | sort -t _ -k 2,2 | tail -n 1`
             echo $dependency_file
             cat $dependency_file


     elif [[ $user_action == "e" ]]; then
             echo "Copying test Results, Logs and JSONs to ", $RESULTS_BUCKET
             ./push_s3.sh



     elif [[ $user_action == "f" ]]; then
             exit
     else
             echo "Nothing was entered correctly"
             exit
     fi
 done
