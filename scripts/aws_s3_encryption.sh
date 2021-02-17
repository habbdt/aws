#!/bin/bash

# check s3 buckets encryption

BUCKETS="$(aws s3api list-buckets --query 'Buckets[].Name' | jq '.[]' | sed 's/\"//g' | tr ' ' '\n')"

echo "Bucket_Name, Encryption"

for bucket in $BUCKETS; do
  ENCR="$(aws s3api get-bucket-encryption --bucket $bucket >/dev/null 2>&1)"
  RETVAL=$?

  if [ $RETVAL -ne 0 ]
  then
    echo "$bucket, NOT-ENCRYPTED"
  else
    echo "$bucket, encrypted"
  fi
done