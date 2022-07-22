#!/bin/bash
    
    testfile=$(ls | grep domain.txt)

    for file in "${testfile[@]}"; do 
        cat $file > all-dbs
    done

    LINES=($(cat all-dbs))  

    for line in  "${LINES[@]}"; do 
        instanceid=$(aws rds describe-db-instances --filters Name=db-instance-id,Values="$line")
        instancename=$(echo $instanceid | jq -r '.DBInstances[].DBInstanceIdentifier')
        sgroups=($( echo $instanceid | jq -r '.DBInstances[].VpcSecurityGroups[].VpcSecurityGroupId'))


        echo DB INSTANCE: $instancename
    for group in "${sgroups[@]}"; do 
         groupcmd=$(aws ec2 describe-security-groups --group-id "$group")
         echo  -e ' \t ' SECURITY GROUP: $(echo $groupcmd | jq -r '.SecurityGroups[].GroupName') SGID: $group
         echo 
         echo SECURITY GROUP RULES PRINTING BELOW FOR $group
         aws ec2 describe-security-group-rules --filter Name="group-id",Values="$group" | jq -r '.SecurityGroupRules[]'
    done
        echo "###################"
    done 