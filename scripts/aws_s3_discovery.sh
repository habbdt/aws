#!/bin/bash

################read-me#############
# scan s3 buckets for
# (1) expiry date
# (2) bucket creation time
# (3) last object modified
# (4) location
# (5) bucket creator/owner
####################################


BUCKETS="$(aws s3api list-buckets --query 'Buckets[].Name' | jq '.[]' | sed 's/\"//g' | tr ' ' '\n')"
BUCKET_CREATION_TIMESTAMP="$(aws s3api list-buckets | jq '.Buckets |.[]|  join(", ")'  | sed 's/"//g' >> /tmp/buckets_creation.tmp)"
echo "Bucket Name, Size, Expiry(days), Created At(ctime), Last Modified (mtime), Location"

function discover() {
    for bucket in $BUCKETS; do

      # last modified objects
      TIMESTAMP_LAST_MODIFIED="$(aws s3 ls $bucket --recursive | sort | tail -n 1)"

      # get bucket location
      BUCKET_LOCATION="$(aws s3api get-bucket-location --bucket $bucket | jq '.LocationConstraint')"

      # bucket creation timestamp
      CREATION_TIME="$(egrep $bucket /tmp/buckets_creation.tmp | cut -d "," -f2 |xargs)"

      # get bucket size
      BUCKET_SIZE="$(aws s3 ls s3://$bucket --summarize --human-readable --recursive \
                     | egrep "Total Size" | cut -d ":" -f2-)"

      # lifecycle expiry
      LIFECYCLE="$(aws s3api get-bucket-lifecycle --bucket  $bucket >/dev/null 2>&1)"
      RETVAL=$?

      if [ $RETVAL -ne 0 ]
      then
        # no lifecycle policy - object will reside ever
        if [ -z "$TIMESTAMP_LAST_MODIFIED" ]
        then
          # bucket is empty
          echo "$bucket, $BUCKET_SIZE, NO_LIFECYCLE, $CREATION_TIME,EMPTY_BUCKET,$BUCKET_LOCATION"
        else
          :
        fi
      else
        EXPIRATION="$(aws s3api get-bucket-lifecycle --bucket $bucket| jq '.Rules|.[].Expiration.Days')"
        echo "$bucket, $BUCKET_SIZE, $EXPIRATION, $CREATION_TIME, $TIMESTAMP_LAST_MODIFIED, $BUCKET_LOCATION"
      fi
    done
}

function cleanup() {
    rm -rf /tmp/buckets_creation.tmp
}

# run function

discover
cleanup
