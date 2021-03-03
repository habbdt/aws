#!/bin/bash

##################read-me##############
# s3 bucket last object modified
#######################################

OPTIONS=$1

if [ "$#" -ne 1 ]
then
    echo "Usage: aws_s3_last_file_modified.sh <s3_bucket_name>"
    echo "s3_bucket_name: all-buckets, specific_bucket_name (single bucket name)"
    exit
fi

# last object modified - all buckets
function all-buckets() {
    BUCKETS="$(aws s3api list-buckets --query 'Buckets[].Name' | jq '.[]' | sed 's/\"//g' | tr ' ' '\n')"

    for bucket in $BUCKETS; do
      TIMESTAMP_LAST_MODIFIED="$(aws s3 ls $bucket --recursive | sort | tail -n 3)"
      if [ -z "$TIMESTAMP_LAST_MODIFIED" ]
      then
        echo "bucket - $bucket is EMPTY"
        echo ""
      else
        echo "bucket - $bucket: last file modified"
        echo "$TIMESTAMP_LAST_MODIFIED"
        echo ""
      fi
    done
}

# last object modified - specific bucket
function specific_bucket_name() {
    BUCKET=$OPTIONS
    TIMESTAMP_LAST_MODIFIED="$(aws s3 ls $BUCKET --recursive | sort | tail -n 3)"
    if [ -z "$TIMESTAMP_LAST_MODIFIED" ]
    then
      echo "bucket - $BUCKET is EMPTY"
      echo ""
    else
      echo "bucket - $BUCKET: last file modified"
      echo "$TIMESTAMP_LAST_MODIFIED"
      echo ""
    fi
}

# select right function based on input
if [ $OPTIONS == "all-buckets" ]
then
  all-buckets
else
  specific_bucket_name
fi