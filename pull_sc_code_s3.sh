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
  echo "Checking if access tokens are updated...."
  if [[ -z "${!1}" ]]; then
    echo "Require Env.$1... Not Found"
    exit 1
  fi
  #echo Require Env.$1... OK "(${!1})"
}


#require_env AWS_ACCESS_KEY_ID
#require_env AWS_SECRET_ACCESS_KEY
#require_env AWS_SESSION_TOKEN



function s3_bucket_check {
      echo "Checking the Buckets exist...."
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


function run_automated_tests {
                echo $CODE_REPO_NAME
                echo $each
                echo "&&&&&"
                TEST_DATA_PATH=${CODE_REPO_NAME}/TestAutomation/TestData/${EKS_ENV_NAME}
                if [[ -d "$each" ]]; then
                         echo file does not exist in $TEST_DATA_PATH
                         echo "The specified file doees not exist in path. Download and rerun the tests"
                else
                         echo "file exists in" $TEST_DATA_PATH
                         cd ${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/
                         echo $each
                         ls -lart
                         pwd
                         python3 main_csv.py /cicd/$each
                fi
}


#echo $BUCKET_NAME
#echo $TEST_DATA_BUCKET
#echo $RESULTS_BUCKET
#echo "*********************************"

s3_bucket_check $BUCKET_NAME
s3_bucket_check $TEST_DATA_BUCKET
s3_bucket_check $RESULTS_BUCKET

while true; do
     echo  -e "Enter the action to be performed. \n
     USAGE: \n
     a - To Pull the code only \n
     b - To Copy test data excel file from S3 \n
     c - To Run Automated Test \n
     d - To view depenedency results file  \n
     e - To view Test logs \n
     f - To Upload Results/Logs/Jsons to S3 \n
     q - To Exit \n"

     echo "<><><><>><><><><><><><><><><><><><><><><><><><><><><><><>"

     read -p 'Enter action to be performed : ' 'user_action'
     echo $user_action


     if [[ $user_action == "a" ]]; then
             read -p 'Enter the Test Automation Code Repo name  without .tar extension: ' 'CODE_REPO_NAME'
             echo $CODE_REPO_NAME
             echo ${BUCKET_NAME}/$CODE_REPO_NAME
             aws s3 cp s3://${BUCKET_NAME}/$CODE_REPO_NAME ./
             if [[ $CODE_REPO_NAME == *".tar"* ]]; then
                tar -xvf  $CODE_REPO_NAME
                $CODE_REPO_NAME = $CODE_REPO_NAME|sed "s/.tar//g"
                echo $CODE_REPO_NAME
             elif [[ $CODE_REPO_NAME == *".zip"* ]]; then
                unzip $CODE_REPO_NAME
                #$CODE_REPO_NAME = $CODE_REPO_NAME|sed "s/'.zip'//g"
                REPO_NAME=`${CODE_REPO_NAME%.*}`
                echo "**************************"
                echo $REPO_NAME
             fi

             cp ./get_token.py $CODE_REPO_NAME/TestAutomation/Code/all_rfss/
             echo "Code download is completed.  The tokens are copied."

     elif [[ $user_action == "b" ]];then
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
             echo -e  "Enter the file name for test execution. You can enter following values \n
             Single file, \n
             comma separated files or \n
             all to run all files"

             read -p 'Enter the file name[s] for test execution. ' 'DATA_FILE'
             DATA_FILE=($(echo $DATA_FILE | tr "," "\n"))
             echo ${DATA_FILE[@]}
             if [[ ${DATA_FILE[@]} != "all" ]];then
                 for each in "${DATA_FILE[@]}"
                 do
                    #echo "*************************************", $each
                    each=${CODE_REPO_NAME}/TestAutomation/TestData/${EKS_ENV_NAME}/$each
                    echo "*************************************", $each
                    run_automated_tests ${CODE_REPO_NAME}/TestAutomation/TestData/${EKS_ENV_NAME}/$each
                  done
             elif [[ ${DATA_FILE[@]} == "all" ]];then
                  echo "Running all  scripts"
                  TEST_DATA_PATH=${CODE_REPO_NAME}/TestAutomation/TestData/${EKS_ENV_NAME}
                  for each in ${CODE_REPO_NAME}/TestAutomation/TestData/${EKS_ENV_NAME}/*
                  do
                    echo "****", $each
                    run_automated_tests $each
                  done
             fi


     elif [[ $user_action == "d" ]]; then
             cd ${CURRENT_PATH}/${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/
             dependency_file=`ls ${CURRENT_PATH}/${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/dependency* | sort -t _ -k 2,2 | tail -n 1`
             echo $dependency_file
             echo "==================================================================================================================================="
             cat $dependency_file
             echo -e "\n ============================================================================================================================="

     elif [[ $user_action == "e" ]]; then
             echo  -e "You have Selected to view logs \n"
             cd ${CURRENT_PATH}/${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/
             log_file=`ls ${CURRENT_PATH}/${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/Test-logs-* | sort -t _ -k 2,2 | tail -n 1`
             echo $log_file
             echo "==================================================================================================================================="
             cat $log_file
             echo -e "\n ============================================================================================================================="


     elif [[ $user_action == "f" ]]; then
             echo "Copying test Results, Logs and JSONs to ", $RESULTS_BUCKET
             cd $CURRENT_PATH
             ./push_s3.sh
             echo "Results are now uploaded to S3"
             echo "Removing results/jsons/csv from local dir"
             cd ${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/
             rm -rf *.json
             rm -rf *.csv
             rm -rf *.log



     elif [[ $user_action == "q" ]]; then
             exit
     else
             echo "Nothing was entered correctly"
             exit
     fi
 done
