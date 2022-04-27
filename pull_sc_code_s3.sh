########################################
#######################################
# 1. Pull Code from S3 or/and 
# 2. Run Auutomated script and 
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




if [[ "$#" -eq 0 ]] || [[ "$#" -gt 2 ]]; then
        echo "Invalid input"
        echo "Usage: Pull_test_code.sh <CODE_REPO_NAME> <TEST_DATA_FILE>"
        exit
else
        CODE_REPO_NAME=$1
        TEST_DATA_FILE=$2
        echo $CODE_REPO_NAME
        echo $TEST_DATA_FILE
fi


BUCKET_NAME="ibm-dish-sourcecode"
echo $BUCKET_NAME


TEST_PATH=${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/
TEST_DATA_PATH=${CODE_REPO_NAME}/TestAutomation/TestData/dish-test

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
     #file_name=$(aws s3 cp "s3://ibm-dish-sourcecode/COMPOSER-Release-0.22.13.tar ./" 2>&1)
     CHECK_FILE_NAME=$(echo $S3_CHECK | grep -c '$CODE_REPO_NAME')
     echo $CHECK_FILE_NAME
     if [[ $CHECK_FILE_NAME = 1 ]]; then
                echo "file exists"
                #aws s3 cp s3://ibm-dish-sourcecode/$CODE_REPO_NAME ./
                #tar -xvf  $CODE_REPO_NAME
     else
             echo  "file name does not exist"
     fi
fi

echo  -e "Enter the action to be performed. \n USAGE: \n a. Code_Pull - to Pull the code only \n b. Run _test - To Run Automated Test \n c. Both - To update the code from S3 and run automated tests"
echo "<><><><>><><><><><><><><><><><><><><><><><><><><><><><><>"
read -p 'Enter action to be performed : ' 'user_action'
echo $user_action


if [[ $user_action == [Cc][Oo][Dd][Ee]_[Pp][Uu][Ll][Ll] ]]; then
        #aws s3 cp s3://ibm-dish-sourcecode/$CODE_REPO_NAME ./
        #tar -xvf  $CODE_REPO_NAME
        echo "pulling code"

elif [[ $user_action == [Rr][Uu][Nn]_[Tt][Ee][Ss][Tt] ]]; then
        cd $TEST_PATH
        python3 main_csv.py $TEST_DATA_PATH/$TEST_DATA_FILE

elif [[ $user_action == [Bb][Oo][Tt][Hh] ]]; then
        #aws s3 cp s3://ibm-dish-sourcecode/$CODE_REPO_NAME ./
        #tar -xvf  $CODE_REPO_NAME
        #cd ${TEST_PATH}
        python3 main_csv.py $TEST_DATA_PATH/$TEST_DATA_FILE
else
        echo "Nothing was entered correctly"
        exit
fi
