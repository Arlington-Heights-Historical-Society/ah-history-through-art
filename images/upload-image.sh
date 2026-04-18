#!/bin bash

BUCKET=ah-history-art-img-20260414021412244200000001

aws s3 cp hana/house-in-1915.webp "s3://$BUCKET/images/histart/hana/house-in-1915.webp"

