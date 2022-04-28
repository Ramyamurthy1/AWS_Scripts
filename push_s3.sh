#!/bin/bash


source env_variables

NavFile()
{
        path=$1
        fileName=$2
        s3Url=$3
        Results_Dir=$4

        cd $path

        if [[ "$fileName" =~ Test-Results.*.csv ]]; then
                echo "<><><><><><> PUSHING $fileName CSV file <><><><><><>"
                filePath="${1}${fileName}"
                echo "Debug: Pushing ${fileName} to Bucket ${s3Url}"
                cmdToRun="aws s3 cp ${filePath} ${s3Url}${Results_Dir}/Results/"
                echo "Debug: Command to Copy CSV to S3 : " $cmdToRun
                copyCsvToS3=$(eval "$cmdToRun")
                echo "<><><><><><> Pushed $fileName CSV fileName <><><><><><>"
        fi
        if [[ "$fileName" =~ Test-log.*.log ]]; then
                echo "<><><><><><> PUSHING $fileName LOG file <><><><><><>"
                filePath="${1}${fileName}"
                echo "Debug: Pushing ${fileName} to Bucket ${s3Url}"
                cmdToRun="aws s3 cp ${filePath} ${s3Url}${Results_Dir}/Logs/"
                echo "Debug: Command to Copy LOG to S3 : " $cmdToRun
                copyCsvToS3=$(eval "$cmdToRun")
                echo "<><><><><><> Pushed $fileName LOG fileName <><><><><><>"
        fi
        if [[ "$fileName" =~ .*.json ]]; then
                echo "<><><><><><> PUSHING $fileName JSON file <><><><><><>"
                filePath="${1}${fileName}"
                echo "Debug: Pushing ${fileName} to Bucket ${s3Url}"
                cmdToRun="aws s3 cp ${filePath} ${s3Url}${Results_Dir}/TMF/"
                echo "Debug: Command to Copy JSON to S3 : " $cmdToRun
                copyCsvToS3=$(eval "$cmdToRun")
                echo "<><><><><><> Pushed $fileName JSON file <><><><><><>"
        fi
}

Results_Folder="Results"-$(date +"%Y-%m-%d-%T")



file_path=${CURRENT_PATH}/${CODE_REPO_NAME}/TestAutomation/Code/all_rfss/
cd $file_path
for file in *
do
                NavFile $file_path $file s3://$RESULTS_BUCKET/ $Results_Folder

done
