#!/bin/bash

#####################ReadMe#########
# check information about s3 bucket
####################################

SVC=$1

if [ "$#" -ne 1 ]
then
    echo "Usage: aws_s3_checker.sh <scan_s3_for>"
    echo "scan_s3_for: all (execept acl) or
          get-bucket-acl,get-bucket-encryption, get-bucket-versioning,
          get-bucket-replication,get-bucket-tagging,get-bucket-website,
          get-bucket-request-payment,get-bucket-notification-configuration,get-bucket-policy-status,
          get-bucket-location,get-bucket-lifecycle-configuration,get-bucket-size"
    exit
fi

BUCKETS="$(aws s3api list-buckets --query 'Buckets[].Name' | jq '.[]' | sed 's/\"//g' | tr ' ' '\n')"

# check bucket acls
function get-bucket-acl() {
    for bucket in $BUCKETS; do
      BUCKET_ACLS="$(aws s3api get-bucket-acl --bucket $bucket)"
      echo "acl for bucket $bucket"
      echo "$BUCKET_ACLS"
    done
}

# check if bucket encryption is enabled
function get-bucket-encryption() {
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
}

# check of bucket versioning is enabled
function   get-bucket-versioning() {
    for bucket in $BUCKETS; do
      VERSIONING="$(aws s3api   get-bucket-versioning --bucket $bucket | jq '.Status')"

      if [ -z "$VERSIONING" ]
      then
        echo "$bucket, VERSIONING-DISABLED"
      else
        echo "$bucket, versioning-enabled"
      fi
    done
}

# check of any replication is configured
function get-bucket-replication() {
    for bucket in $BUCKETS; do
      REPLICATION="$(aws s3api get-bucket-replication --bucket $bucket >/dev/null 2>&1)"
      RETVAL=$?

      if [ $RETVAL -ne 0 ]
      then
        echo "$bucket, NO-BUCKET-REPLICATION"
      else
        echo "$bucket, replication-configured"
      fi
    done
}

# check of s3 bucket with any tags
function get-bucket-tagging() {
    for bucket in $BUCKETS; do
      TAGGING="$(aws s3api get-bucket-tagging --bucket $bucket >/dev/null 2>&1)"
      RETVAL=$?

      if [ $RETVAL -ne 0 ]
      then
        echo "$bucket, NO-TAG-FOUND"
      else
        echo "$bucket, tag-found-investigate"
      fi
    done
}


# check if s3 bucket is hosting a static website
function get-bucket-website() {
    for bucket in $BUCKETS; do
      WEBSITE="$(aws s3api get-bucket-website --bucket $bucket >/dev/null 2>&1)"
      RETVAL=$?

      if [ $RETVAL -ne 0 ]
      then
        echo "$bucket, NO-WEBSITE-FOUND"
      else
        echo "$bucket, website-config-found-investigate"
      fi
    done
}

# check who will pay requester or bucketowner
function get-bucket-request-payment() {
    for bucket in $BUCKETS; do
      WHO_PAYS="$(aws s3api get-bucket-request-payment  --bucket $bucket | jq '.Payer')"

      if [[ "$WHO_PAYS" == "Requester" ]]
      then
        echo "$bucket, REQUESTER-PAYS"
      else
        echo "$bucket, bucketowner-pays"
      fi
    done
}

# get s3 bucket notification configuration

function get-bucket-notification-configuration() {
    for bucket in $BUCKETS; do
      NOTIFICATION_CONFIG="$(aws s3api get-bucket-notification-configuration --bucket $bucket)"

      if [ -z "$NOTIFICATION_CONFIG" ]
      then
        echo "$bucket, NO-NOTIFICATION-CONFIG"
      else
        echo "$bucket, custom-notification-configured-investigate"
      fi
    done
}

# check if s3 bucket has any policy
function get-bucket-policy-status() {
    for bucket in $BUCKETS; do
      POLICY_STATUS="$(aws s3api get-bucket-policy-status --bucket $bucket >/dev/null 2>&1)"
      RETVAL=$?

      if [ $RETVAL -ne 0 ]
      then
        echo "$bucket, NO-POLICY_FOUND"
      else
        echo "$bucket, policy-found-investigate"
      fi
    done
}

# print bucket location

function get-bucket-location() {
  for bucket in $BUCKETS; do
    BUCKET_LOCATION="$(aws s3api get-bucket-location --bucket $bucket | jq '.LocationConstraint')"
    echo "$bucket, location: $BUCKET_LOCATION"
  done
}

# check lifecycle policy

function   get-bucket-lifecycle-configuration() {
  for bucket in $BUCKETS; do
    LIFECYCLE="$(aws s3api get-bucket-lifecycle-configuration --bucket $bucket >/dev/null 2>&1)"
    RETVAL=$?

    if [ $RETVAL -ne 0 ]
      then
        echo "$bucket, NO-LIFECYCLE-POLICY"
      else
        echo "$bucket, lifecycle-policy-found-investigate"
      fi
  done
}

# check buckets size

function get-bucket-size() {
    echo "BUCKET_NAME, BUCKET_SIZE (MB)"
    for bucket in $BUCKETS; do
      BUCKET_SIZE="$(aws s3 ls s3://$bucket --summarize --human-readable --recursive \
                     | egrep "Total Size" | cut -d ":" -f2-)"

      echo "$bucket, $BUCKET_SIZE"
    done
}

# case

case $SVC in

  all)


esac

case $SVC in

  all)
    get-bucket-encryption
    get-bucket-versioning
    get-bucket-replication
    get-bucket-tagging
    get-bucket-website
    get-bucket-request-payment
    get-bucket-notification-configuration
    get-bucket-policy-status
    get-bucket-location
    get-bucket-lifecycle-configuration
    get-bucket-size
    ;;

  get-bucket-acl)
    get-bucket-acl
    ;;

  get-bucket-encryption)
    get-bucket-encryption
    ;;

  get-bucket-versioning)
    get-bucket-versioning
    ;;

  get-bucket-replication)
    get-bucket-replication
    ;;

  get-bucket-tagging)
    get-bucket-tagging
    ;;

  get-bucket-website)
    get-bucket-website
    ;;

  get-bucket-request-payment)
    get-bucket-request-payment
    ;;

  get-bucket-notification-configuration)
    get-bucket-notification-configuration
    ;;

  get-bucket-policy-status)
    get-bucket-policy-status
    ;;

  get-bucket-location)
    get-bucket-location
    ;;

  get-bucket-lifecycle-configuration)
    get-bucket-lifecycle-configuration
    ;;

  get-bucket-size)
    get-bucket-size
    ;;

esac