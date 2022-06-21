#!/bin/bash

test=deploy/build1-east1-us-prod/helm/cert-manager/manifest.yaml

base=$(dirname $test)
base1=$(basename $base) 
base2=$(dirname $base)
base3=$(dirname $base2)
base4=$(basename $base3)

echo $base1
echo $base4
