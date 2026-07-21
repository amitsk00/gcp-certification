#!/usr/bin/bash


NL="\n"
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
NC="\e[1;0m"

declare -a myArray 

function processListFiles(){

    listFile=$1
    myArray=()
    OLD_IFS="$IFS"
    IFS=$'\n'

    while read myLine
    do 
        flagSkip=false

        # check line for some conditions
        if [[ "$myLine" == *"#"* ]]; then 
            # echo -e "contains comment char - ${myLine}"
            flagSkip=true
        fi 

        if [[ -z ${myLine} ]]; then
            # echo -e "skipping blank line - ${myLine}"      
            flagSkip=true  
        fi 

        # lines checked, skip errors and process proper data
        if [[  ${flagSkip} == true ]]; then
            # echo -e "skipping line - ${myLine}"
            continue 
        else
            # echo -e "adding to array - ${myLine} "
            myArray+=(${myLine})

            # declare -p myArray
        fi 

    done  < <(cat ${listFile} ) 

    IFS="$OLD_IFS"

    # for item in ${myArray[@]}
    # do 
    #     echo ${item}
    # done 


}



#########################################################
#########################################################

echo -e "starting GCP setup" 

# my project ID here
PROJECT_ID="XXX"
# gcloud config set project $PROJECT_ID




#########################################################
#########################################################

echo -e "${GREEN} ${NL} Working with APIs ${NL}  ${NC}" 
param1="api.list"


processListFiles $param1
declare -n myArrApi=myArray


# enable the list of APIs
for api in  "${myArrApi[@]}"  
do 
    echo ${api}
    # gcloud services enable ${api} --async
done 

# for i in "${!myArrApi[@]}"
# do 
#     echo -e "index is ${i} , item is ${myArrApi[$i]}"
# done 







#########################################################
#########################################################

# Service Accounts

echo -e "${GREEN} ${NL} Working with APIs ${NL}  ${NC}" 
param1="sa.list"

processListFiles $param1
declare -n myArrSA=myArray

# enable the list of APIs
for saDeets in  "${myArrSA[@]}"  
do 
    # echo ${saDeets}
    saName=$(echo $saDeets | awk -F',' '{ print $1 }' )
    saDescr=$(echo $saDeets | awk -F',' '{ print $2 }' )
    echo -e " SA Name is ~${saName}~ and SA Descr is ~${saDescr}~  "
    # create SA here
done 



#########################################################
#########################################################

## SA Role Binding



#########################################################
#########################################################

# Network part

# gcloud compute networks create labnet --subnet-mode=custom

# gcloud compute networks subnets create labnet-sub \
#    --network labnet \
#    --region us-central1 \
#    --range 10.0.0.0/28

# gcloud compute firewall-rules create labnet-allow-internal \
# 	--network=labnet \
# 	--action=ALLOW \
# 	--rules=icmp,tcp:22 \
# 	--source-ranges=0.0.0.0/0

