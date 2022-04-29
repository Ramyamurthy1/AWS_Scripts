
#####################################################################
# 1. Pull Code from S3                                              #
# 2. Copy the test data file from s3 in case not present in github  #
# 3. Run Automated script                                           #
# 4. View depenedency results file                                  #
# 5. Upload the results to s3                                       #
# 6. Clean up the dir by removing the logs, jsons and csv file      #
# ################################################################### 



###########################################################################################
# PRE-REQUISITES                                                                          #
# Latest Code must be present in S3 bucket under the BUCKET name and not within sub dirs  #
# env_Variables file is updated with BUCKET information                                   #
# "token_url" file fie is updated with the correct URL'S                                  #
# #########################################################################################


#################################################################################################
#  STEPS to Run the Tests                                                                       #
#  ========================                                                                     #
#  1. Clone the s3_pull_code dir to the local folder where you want to run the tests            #
#  2. Update env_variables file with bucket information                                         #
#  3. Update the token_url file ith latest URLS according to the env                            #
#  4. Run "./pull_test_code.sh"                                                                 #
#  5. Select the required option                                                                #
##################################################################################################


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
echo $RESULTS_BUCKET
echo "*********************************"

s3_bucket_check $BUCKET_NAME
s3_bucket_check $TEST_DATA_BUCKET
s3_bucket_check $RESULTS_BUCKET

while true; do
     echo  -e "Enter the action to be performed. \n USAGE: \n a - To Pull the code only \n b - To Copy test data excel file from S3 \n c - To Run Automated Test \n d - To view depenedency results file  \n e -  Upload Results/Logs/Jsons to S3 \n f -  To Exit"
     echo "<><><><>><><><><><><><><><><><><><><><><><><><><><><><><>"

     read -p 'Enter action to be performed : ' 'user_action'
     echo $user_action


     if [[ $user_action == "a" ]]; then
             echo  -e "You have Selected to Copy the Latest code from S3 \n"
             read -p 'Enter the Test Automation Code Repo name : ' 'CODE_REPO_NAME'
             echo $CODE_REPO_NAME
             aws s3 cp s3://${BUCKET_NAME}/$CODE_REPO_NAME ./
             tar -xvf  $CODE_REPO_NAME.tar
             cp ./get_token.py $CODE_REPO_NAME/TestAutomation/Code/all_rfss/
             echo "Code download is completed.  The tokens are copied."

     elif [[ $user_action == "b" ]];then
             echo  -e "You have Selected to Copy test data deom S3 bucket \n"
             read -p 'Enter the file name to be copied: ' 'DATA_FILE'
             echo $DATA_FILE

             #aws s3 ls s3://$TEST_DATA_BUCKET
             TEST_DATA_PATH=${CODE_REPO_NAME}/TestAutomation/TestData/${EKS_ENV_NAME}

             aws s3 cp s3://$TEST_DATA_BUCKET/$DATA_FILE ${CURRENT_PATH}/${TEST_DATA_PATH}
             echo -e "Download complete \n"
             echo "====================================================================================================="


     elif [[ $user_action == "c" ]]; then
             #read -p 'Enter the code repo release : ' 'CODE_REPO_NAME'
             echo  -e "You have Selected to run the automated tests \n"
             echo "Folowing files Exist. Select the fie you want to run"
             ls -lrt ${CODE_REPO_NAME}/TestAutomation/TestData/${EKS_ENV_NAME}
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
             echo  -e "You have Selected to view the dependency results file generated. \n"
             cd ${CURRENT_PATH}/${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/
             dependency_file=`ls ${CURRENT_PATH}/${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/dependency* | sort -t _ -k 2,2 | tail -n 1`
             echo $dependency_file
             echo -e "=============================================================================================================================\n"
             cat $dependency_file
             echo -e "============================================================================================================================="


     elif [[ $user_action == "e" ]]; then
             echo  -e "You have Selected to Copy the Test Results, Test Logs and TMF orders to S3. \n"
             echo "Copying test Results, Logs and JSONs to ", $RESULTS_BUCKET
             cd $CURRENT_PATH
             ./push_s3.sh



     elif [[ $user_action == "f" ]]; then
             echo  -e "You have Selected to exit. \n"
             exit
     else
             echo "Nothing was entered correctly. Select correct option"
             exit
     fi
 done
