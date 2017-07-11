#!/bin/bash

cluster="onkyo-ecs-cluster-qa"
echo ECS_CLUSTER="${cluster}" >> /etc/ecs/ecs.config

#task_def="dd-agent-task"
#start ecs
#sleep 10

#yum install -y aws-cli jq 

#instance_arn=$(curl -s http://localhost:51678/v1/metadata | jq -r ‘. | .ContainerInstanceArn’ | awk -F/ ‘{print $NF}’ ) 
#az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone) 

#region=${az:0:${#az} - 1} 
#echo “cluster=$cluster az=$az region=$region aws ecs start-task –cluster $cluster –task-definition $task_def –container-instances $instance_arn –region $region” >> /etc/rc.local