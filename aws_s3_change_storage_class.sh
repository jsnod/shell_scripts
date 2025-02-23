#!/bin/bash

# Recursively changes the storage class of all objects in the specified bucket/prefix.
#
# Requires: jq, aws-cli
#
# NOTE: This assumes that objects already exist in a class with "Immediate" restore time, or have already been restored
# from a non-Immediate (eg: Glacier) storage class.
#
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html#sc-compare
#
# Usage: ./aws_s3_change_storage_class.sh your-bucket-name your-folder-prefix/ STANDARD_IA

# Enable debugging
#set -x

# Function to change the storage class of an S3 object
change_storage_class() {
    local bucket_name=$1
    local key=$2
    local new_storage_class=$3

    echo "Changing storage class of s3://$bucket_name/$key to $new_storage_class"

    aws s3 cp "s3://$bucket_name/$key" "s3://$bucket_name/$key" --storage-class $new_storage_class
}

# Main function
main() {
    local bucket_name=$1
    local prefix=$2
    local new_storage_class=$3

    if [[ -z "$bucket_name" || -z "$prefix" || -z "$new_storage_class" ]]; then
        echo "Usage: $0 <bucket-name> <prefix> <new-storage-class>"
        exit 1
    fi

    # List all objects under the specified prefix in JSON format and iterate over each key
    aws s3api list-objects-v2 --bucket "$bucket_name" --prefix "$prefix" --query 'Contents[].Key' --output json | jq -r '.[]' | while IFS= read -r key; do
        change_storage_class "$bucket_name" "$key" "$new_storage_class"
    done

    echo
    echo "DONE!"
    echo
}

# Run the main function with command-line arguments
main "$@"
