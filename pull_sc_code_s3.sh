########################################
#######################################
# 1. Pull Code from S3
# 2. Run Auutomated script
# 3. Upload the results to s3
###########################################
##########################################

require_env() {
  if [[ -z "${!1}" ]]; then
    echo "Require Env.$1... Not Found"
    exit 1
  fi
  echo Require Env.$1... OK "(${!1})"
}


'''

if [[ "$#" -eq 0 ]]; then
        echo "Invalid input"
        echo "Usage: Pull_test_code.sh <CODE_REPO_NAME>"
        exit
else
        CODE_REPO_NAME=$1
        TEST_DATA_FILE=$2
        echo $CODE_REPO_NAME
        echo $TEST_DATA_FILE
fi
'''

BUCKET_NAME="ibm-dish-sourcecode"
TEST_DATA_BUCKET="ibm-dish-sourcecode"



require_env AWS_ACCESS_KEY_ID
require_env AWS_SECRET_ACCESS_KEY
require_env AWS_SESSION_TOKEN




S3_CHECK=$(aws s3 ls "s3://${BUCKET_NAME}" 2>&1)
if [ $? != 0 ]
then
  NO_BUCKET_CHECK=$(echo $S3_CHECK | grep -c 'NoSuchBucket')
  if [ $NO_BUCKET_CHECK = 1 ]; then
          echo "Bucket does not exist"
          exit 0
  fi

else
     echo "Bucket Exists $BUCKET_NAME"
     CHECK_FILE_NAME=$(echo $S3_CHECK | grep -c $CODE_REPO_NAME)
     echo $CHECK_FILE_NAME
     if [[ $CHECK_FILE_NAME = 1 ]]; then
                echo "file exists"
                #aws s3 cp s3://ibm-dish-sourcecode/$CODE_REPO_NAME ./
                #tar -xvf  $CODE_REPO_NAME
     else
             echo  "file name does not exist"
     fi
fi


while true; do

     echo  -e "Enter the action to be performed. \n USAGE: \n a - to Pull the code only \n b - To Run Automated Test \n c - To update the code from S3 and run automated tests \n d - To Copy test data excel file from S3 \n e - to Exit"
     echo "<><><><>><><><><><><><><><><><><><><><><><><><><><><><><>"
     read -p 'Enter action to be performed : ' 'user_action'
     echo $user_action


     if [[ $user_action == "a" ]]; then
             read -p 'Enter the Test Automation Code Repo name : ' 'CODE_REPO_NAME'
             echo $CODE_REPO_NAME
             export $CODE_REPO_NAME
             #aws s3 cp s3://ibm-dish-sourcecode/$CODE_REPO_NAME ./
             #tar -xvf  $CODE_REPO_NAME
             echo "pulling code"

     elif [[ $user_action == "b" ]]; then
             read -p 'Enter the code repo release : ' 'CODE_REPO_NAME'
             read -p 'Enter the file name for test execution : ' 'DATA_FILE'
             echo $CODE_REPO_NAME
             echo ${DATA_FILE}
             TEST_DATA_PATH=${CODE_REPO_NAME}/TestAutomation/TestData/dish-test
             TEST_DATA_FILE=/testing-cicd/${TEST_DATA_PATH}/${DATA_FILE}
             echo "******"
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

     elif [[ $user_action == "c" ]]; then
             #aws s3 cp s3://ibm-dish-sourcecode/$CODE_REPO_NAME ./
             #tar -xvf  $CODE_REPO_NAME
             #cd ${TEST_PATH}
             python3 main_csv.py $TEST_DATA_PATH/$TEST_DATA_FILE
     elif [[ $user_action == "d" ]];then
             read -p 'Enter the file name to be copied: ' 'DATA_FILE'
             echo $DATA_FILE
             #aws s3 ls s3://$TEST_DATA_BUCKET
             aws s3 cp s3://$TEST_DATA_BUCKET/$DATA_FILE $TEST_DATA_PATH
     elif [[ $user_action == "e" ]]; then
             exit
     else
             echo "Nothing was entered correctly"
             exit
     fi
 done
