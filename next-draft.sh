#!/bin/bash

# List each sox tag
  soxtags=("everquote:domain" "everquote:sox:platform" "everquote:sox:cname")

# Iterate through each tag and ensure blank values are identified 
  for i in "${soxtags[@]}"
  do
  aws resourcegroupstaggingapi get-resources --resource-type-filters rds:db --tag-filters  Key=$i,Values="" --output json | jq -r '.ResourceTagMappingList[].ResourceARN'  >> nonsoxcompliantdbs.txt 
  done

# The following dbs are not compliant with sox-Domain has not been set
  echo There are $(cat nonsoxcompliantdbs.txt | sort -u | wc -l) databases that are not sox compliant, they are listed below
  cat nonsoxcompliantdbs.txt | sort -u 

# Get a list of all the different domain tags, store them in a file for sorting 
  aws resourcegroupstaggingapi get-resources --resource-type-filters rds:db --tag-filters  Key=everquote:domain --output json | jq -r '.ResourceTagMappingList[].Tags[] | select(.Key=="everquote:domain").Value' > alldomains.txt
  all_domains=($(cat alldomains.txt | sort -u))

# Populate databases per domain 
  for i in "${all_domains[@]}";do
  aws resourcegroupstaggingapi get-resources --resource-type-filters rds:db --tag-filters  Key=everquote:domain,Values="$i" --output json | jq -r '.ResourceTagMappingList[].ResourceARN' > "$i"-domain 
  done

# Filter through each domain and return the number of db in each 
  files=$(ls | grep domain)
  for file in $files; do 
    if [[ $file == connect-domain ]]; then  # Delete db's from connect that have been identified as not sox compliant
     sed '/router/d' ./connect-domain > test && mv test connect-domain
    fi
   echo $file has $(cat "$file" | wc -l) databases
  done

# Platforms under each domain 
  domainfiles=("acquire-domain" "connect-domain" "cover-domain" "enable-domain")
  

# Cleanup
  rm alldomains.txt
  rm nonsoxcompliantdbs.txt
