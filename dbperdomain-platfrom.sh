#!/bin/bash

# List each sox tag
  soxtags=("everquote:domain" "everquote:sox:platform" "everquote:sox:cname")

# Iterate through each tag and ensure blank values are identified 
  for i in "${soxtags[@]}"
  do
  aws resourcegroupstaggingapi get-resources --resource-type-filters rds:db --tag-filters  Key=$i,Values="" --output json | jq -r '.ResourceTagMappingList[].ResourceARN'  >> nonsoxcompliantdbs
  done

# The following dbs are not compliant with sox-Domain has not been set
  echo There are $(cat nonsoxcompliantdbs | sort -u | wc -l) databases that are not sox compliant, they are listed below
  cat nonsoxcompliantdbs | sort -u 

# Get a list of all the different domain tags, store them in a file for sorting 
  aws resourcegroupstaggingapi get-resources --resource-type-filters rds:db --tag-filters  Key=everquote:domain --output json | jq -r '.ResourceTagMappingList[].Tags[] | select(.Key=="everquote:domain").Value' > alldomains.txt
  all_domains=($(cat alldomains.txt | sort -u))

# Populate databases per domain 
  for i in "${all_domains[@]}";do
  echo "##########################"
# Get all of the domains first of all 
  aws resourcegroupstaggingapi get-resources --resource-type-filters rds:db --tag-filters  Key=everquote:domain,Values="$i" --output json | jq '.ResourceTagMappingList[].ResourceARN' > "$i"-domain.txt
# Now for each domain get me each unique platform and store them in a file for each domain
  aws resourcegroupstaggingapi get-resources --resource-type-filters rds:db --tag-filters  Key=everquote:domain,Values="$i" --output json | jq -r '.ResourceTagMappingList[].Tags[] | select(.Key=="everquote:sox:platform").Value' | sort -u > "$i"-allplatforms  
# Store each platform in each domain in an array
  all_platforms=($(cat "$i"-allplatforms | sort -u))
# Iterate through the platform array for each domain and populate the ARN's for each domain and platform combination
  for platform in "${all_platforms[@]}"; do
  aws resourcegroupstaggingapi get-resources --resource-type-filters rds:db --tag-filters  Key=everquote:domain,Values="$i" Key=everquote:sox:platform,Values="$platform" --output json | jq '.ResourceTagMappingList[].ResourceARN' > "$i"-"$platform" 
  done
  rm "$i"-allplatforms
  done
  rm alldomains.txt
  
# Filter through each domain and return the number of db in each 
  files=$(ls | grep domain.txt)
  platformfiles=$(ls | grep platform)
  for file in $files; do 
    if [[ $file == connect-domain.txt ]]; then  # Delete db's from connect that have been identified as not sox compliant
     sed '/router/d' ./connect-domain.txt > test && mv test connect-domain.txt
    fi
   echo $file has $(cat "$file" | wc -l) databases
  done
  echo
# Breakdown of databases within each platform on each domain
   for platformfile in $platformfiles; do 
      echo $platformfile has $(cat "$platformfile" | wc -l) databases
      echo $(cat "$platformfile")
      echo
   done 


# Cleanup
  
 rm *-platform
