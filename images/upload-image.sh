#!/bin/bash

# script assumes BUCKET and AWS_PROFILE are set in the environment.

local_path="$1"
if [[ -z "$local_path" ]]; then
  echo "error: missing local image path. Pass the file path as the first argument" >&2
  exit 1
fi

aws s3 cp "$local_path" "s3://$BUCKET/images/histart/$local_path"

echo "URL is:"
echo "https://d2fyd5kvehusob.cloudfront.net/images/histart/$local_path"
