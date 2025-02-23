#!/bin/bash

# Recursively lists the storage class and restore status of all objects in all buckets of the current account
# or a specific bucket and prefix if provided.
#
# Requires: jq, aws-cli
#
# Usage: ./aws_s3_list_object_storage_class.sh [bucket-name] [prefix]

# Enable debugging
#set -x

# Function to print the storage class and restore status of an S3 object
print_storage_class_and_restore_status() {
    local bucket_name=$1
    local key=$2

    storage_class=$(aws s3api head-object --bucket "$bucket_name" --key "$key" --query 'StorageClass' --output text)
    restore_status=$(aws s3api head-object --bucket "$bucket_name" --key "$key" --query 'Restore' --output text)
    echo "s3://$bucket_name/$key - Storage Class: $storage_class - Restore Status: $restore_status"
}

# Function to list and process all objects in a bucket
process_bucket() {
    local bucket_name=$1
    local prefix=$2

    echo "Processing bucket: $bucket_name with prefix: $prefix"

    # List all objects in the bucket with the specified prefix in JSON format and iterate over each key
    aws s3api list-objects-v2 --bucket "$bucket_name" --prefix "$prefix" --query 'Contents[].Key' --output json | jq -r '.[]' | while IFS= read -r key; do
        print_storage_class_and_restore_status "$bucket_name" "$key"
    done
}

# Main function
main() {
    local specific_bucket=$1
    local prefix=$2

    if [[ -n "$specific_bucket" ]]; then
        # Process the specified bucket and prefix
        process_bucket "$specific_bucket" "$prefix"
    else
        # List all S3 buckets in the account and iterate over each bucket name
        aws s3api list-buckets --query 'Buckets[].Name' --output json | jq -r '.[]' | while IFS= read -r bucket_name; do
            process_bucket "$bucket_name" "$prefix"
        done
    fi

    echo
    echo "DONE!"
    echo
}

# Run the main function with optional bucket name and prefix arguments
main "$1" "$2"
