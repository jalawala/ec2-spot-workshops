#!/bin/bash +x

echo "Hello World from EC2 Spot Team..."
#Global Defaults
DEFAULT_REGION=us-east-1

#Workshop2 Launch Template Configurations settings
INSTANCE_TYPE=t2.micro
DEFAULT_SUBNET=subnet-a2c2fd8c

LAUNCH_TEMPLATE_NAME=EC2SpotWorkshop2_lt
LAUNCH_TEMPLATE_VERSION=1


#Workshop2 ASG Configurations settings
ASG_TEMPLATE_FILE=Workshop2_asg_template.json
ASG_TEMPLATE_TEMP_FILE=Workshop2_asg_template_temp.json

ASG_NAME=EC2SpotWorkshop2_asg2
ASG_LT_NAME=$LAUNCH_TEMPLATE_NAME
ASG_LT_VERSION=$LAUNCH_TEMPLATE_VERSION
ASG_OVERRIDE_INSTANCE_1=m4.large
ASG_OVERRIDE_INSTANCE_2=c4.large
ASG_OVERRIDE_INSTANCE_3=r4.large
ASG_OD_CAPACITY=0
ASG_OD_PERCENTAGE_ABOVE_BASE=50
ASG_OD_ALLOCATIION_STRATEGY=prioritized
ASG_SPOT_ALLOCATIION_STRATEGY=lowest-price
ASG_SPOT_INSTANCE_POOL_COUNT=2
ASG_MIN_SIZE=4
ASG_MAX_SIZE=4
ASG_DESIRED_SIZE=4
ASG_SUBNETS_LIST="subnet-764d7d11,subnet-a2c2fd8c,subnet-cb26e686"


AMI_ID=$(aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????.?-x86_64-gp2' 'Name=state,Values=available' --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' --output text)
echo "Amazon AMI_ID is $AMI_ID"

#LAUCH_TEMPLATE_ID=$(aws ec2 create-launch-template --region $DEFAULT_REGION --launch-template-name $LAUNCH_TEMPLATE_NAME --version-description LAUNCH_TEMPLATE_VERSION --launch-template-data "{\"NetworkInterfaces\":[{\"DeviceIndex\":0,\"SubnetId\":\"$DEFAULT_SUBNET\"}],\"ImageId\":\"$AMI_ID\",\"InstanceType\":\"$INSTANCE_TYPE\",\"TagSpecifications\":[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"$LAUNCH_TEMPLATE_NAME\"}]}]}" | jq -r '.LaunchTemplate.LaunchTemplateId')
LAUCH_TEMPLATE_ID=lt-046437183d3b6bf53
echo "Amazon LAUCH_TEMPLATE_ID is $LAUCH_TEMPLATE_ID"

ASG_LT_ID=$LAUCH_TEMPLATE_ID


cp -Rfp $ASG_TEMPLATE_FILE $ASG_TEMPLATE_TEMP_FILE

echo "Populating ASG configuration for in $ASG_TEMPLATE_TEMP_FILE"

sed -i "s/TMPL_ASG_NAME/$ASG_NAME/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_LT_ID/$ASG_LT_ID/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_LT_NAME/$ASG_LT_NAME/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_LT_VERSION/$ASG_LT_VERSION/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_OVERRIDE_INSTANCE_1/$ASG_OVERRIDE_INSTANCE_1/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_OVERRIDE_INSTANCE_2/$ASG_OVERRIDE_INSTANCE_2/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_OVERRIDE_INSTANCE_3/$ASG_OVERRIDE_INSTANCE_3/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_OD_CAPACITY/$ASG_OD_CAPACITY/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_OD_PERCENTAGE_ABOVE_BASE/$ASG_OD_PERCENTAGE_ABOVE_BASE/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_OD_ALLOCATIION_STRATEGY/$ASG_OD_ALLOCATIION_STRATEGY/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_SPOT_ALLOCATIION_STRATEGY/$ASG_SPOT_ALLOCATIION_STRATEGY/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_SPOT_INSTANCE_POOL_COUNT/$ASG_SPOT_INSTANCE_POOL_COUNT/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_MIN_SIZE/$ASG_MIN_SIZE/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_MAX_SIZE/$ASG_MAX_SIZE/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_DESIRED_SIZE/$ASG_DESIRED_SIZE/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_SUBNETS_LIST/$ASG_SUBNETS_LIST/g" $ASG_TEMPLATE_TEMP_FILE
sed -i "s/TMPL_ASG_TAG_VALUE/$ASG_NAME/g" $ASG_TEMPLATE_TEMP_FILE


echo "Creating the ASG $ASG_NAME using $ASG_TEMPLATE_TEMP_FILE..."

#aws autoscaling create-auto-scaling-group --cli-input-json file://$ASG_TEMPLATE_TEMP_FILE


echo "Creating the Spot Instance using run-instances API..."

#SPOT_INSTANCE_DETAILS=$(aws ec2 run-instances --launch-template LaunchTemplateName=$LAUNCH_TEMPLATE_NAME,Version=$LAUNCH_TEMPLATE_VERSION --instance-market-options MarketType=spot)
#SPOT_INSTANCE_ID=$(echo $SPOT_INSTANCE_DETAILS |jq -r '.Instances[0].InstanceId')
#SPOT_REQUEST_ID=$(echo $SPOT_INSTANCE_DETAILS |jq -r '.Instances[0].SpotInstanceRequestId')

echo "Creating the Spot Instance $SPOT_INSTANCE_ID with Request Id $SPOT_REQUEST_ID..."
#aws ec2 run-instances --launch-template LaunchTemplateName=$LAUNCH_TEMPLATE_NAME,Version=$LAUNCH_TEMPLATE_VERSION


SPOTFLEET_TEMPLATE_INSTANCESPECS_FILE=spot_fleet_with_instancespecs_template.json
SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE=spot_fleet_with_instancespecs_template_temp.json
cp -Rfp $SPOTFLEET_TEMPLATE_INSTANCESPECS_FILE $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE

echo "Populating Spot Fleet configuration for in $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE"

SPOTFLEET_SPOT_ALLOCATIION_STRATEGY=capacityOptimized
SPOTFLEET_TARGET_CAPACITY=2
SPOTFLEET_INSTANCESPEC_1_IMAGE_ID=ami-00dc79254d0461090
SPOTFLEET_INSTANCESPEC_2_IMAGE_ID=ami-0d08fa65f81355d86
SPOTFLEET_INSTANCESPEC_3_IMAGE_ID=ami-00eb20669e0990cb4

SPOTFLEET_INSTANCESPEC_1_INSTANCE_TYPE=c3.large
SPOTFLEET_INSTANCESPEC_2_INSTANCE_TYPE=t3a.medium
SPOTFLEET_INSTANCESPEC_3_INSTANCE_TYPE=t3.medium

SPOTFLEET_INSTANCESPEC_SUBNETS_LIST=subnet-764d7d11,subnet-a2c2fd8c,subnet-cb26e686
SPOTFLEET_INSTANCESPEC_KEY_PAIR=awsajp_keypair


sed -i "s/TMPL_SPOTFLEET_SPOT_ALLOCATIION_STRATEGY/$SPOTFLEET_SPOT_ALLOCATIION_STRATEGY/g" $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_TARGET_CAPACITY/$SPOTFLEET_TARGET_CAPACITY/g" $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_INSTANCESPEC_1_IMAGE_ID/$SPOTFLEET_INSTANCESPEC_3_IMAGE_ID/g" $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_INSTANCESPEC_2_IMAGE_ID/$SPOTFLEET_INSTANCESPEC_2_IMAGE_ID/g" $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_INSTANCESPEC_3_IMAGE_ID/$SPOTFLEET_INSTANCESPEC_3_IMAGE_ID/g" $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_INSTANCESPEC_1_INSTANCE_TYPE/$SPOTFLEET_INSTANCESPEC_1_INSTANCE_TYPE/g" $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_INSTANCESPEC_2_INSTANCE_TYPE/$SPOTFLEET_INSTANCESPEC_2_INSTANCE_TYPE/g" $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_INSTANCESPEC_3_INSTANCE_TYPE/$SPOTFLEET_INSTANCESPEC_3_INSTANCE_TYPE/g" $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE

sed -i "s/TMPL_SPOTFLEET_INSTANCESPEC_SUBNETS_LIST/$SPOTFLEET_INSTANCESPEC_SUBNETS_LIST/g" $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_INSTANCESPEC_KEY_PAIR/$SPOTFLEET_INSTANCESPEC_KEY_PAIR/g" $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE

echo "Creating the Spot Fleet  using $SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE..."

#SPOT_FLEET_REQUEST_ID=$(aws ec2 request-spot-fleet --spot-fleet-request-config file://$SPOTFLEET_TEMPLATE_INSTANCESPECS_TEMP_FILE|jq -r '.SpotFleetRequestId')

#echo "Created the Spot Fleet (using instance specificatons) request id $SPOT_FLEET_REQUEST_ID"



SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_FILE=spot_fleet_with_launchtemplate_template.json
SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE=spot_fleet_with_launchtemplate_template_temp.json
cp -Rfp $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_FILE $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE

echo "Populating Spot Fleet configuration for in $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE"

SPOTFLEET_SPOT_ALLOCATIION_STRATEGY=capacityOptimized
SPOTFLEET_TARGET_CAPACITY=2
SPOTFLEET_OD_TARGET_CAPACITY=1
SPOTFLEET_LAUNCHTEMPLATE_LT_ID=$LAUCH_TEMPLATE_ID
SPOTFLEET_LAUNCHTEMPLATE_LT_VERSION=$LAUNCH_TEMPLATE_VERSION


SPOTFLEET_LAUNCHTEMPLATE_1_INSTANCE_TYPE=c3.large
SPOTFLEET_LAUNCHTEMPLATE_2_INSTANCE_TYPE=t3a.medium
SPOTFLEET_LAUNCHTEMPLATE_3_INSTANCE_TYPE=t3.medium

SPOTFLEET_LAUNCHTEMPLATE_SUBNETS_1=subnet-764d7d11
SPOTFLEET_LAUNCHTEMPLATE_SUBNETS_2=subnet-a2c2fd8c
SPOTFLEET_LAUNCHTEMPLATE_SUBNETS_3=subnet-cb26e686

SPOTFLEET_INSTANCESPEC_KEY_PAIR=awsajp_keypair


sed -i "s/TMPL_SPOTFLEET_SPOT_ALLOCATIION_STRATEGY/$SPOTFLEET_SPOT_ALLOCATIION_STRATEGY/g" $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_TARGET_CAPACITY/$SPOTFLEET_TARGET_CAPACITY/g" $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE

sed -i "s/TMPL_SPOTFLEET_OD_TARGET_CAPACITY/$SPOTFLEET_OD_TARGET_CAPACITY/g" $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_LAUNCHTEMPLATE_LT_ID/$SPOTFLEET_LAUNCHTEMPLATE_LT_ID/g" $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_LAUNCHTEMPLATE_LT_VERSION/$SPOTFLEET_LAUNCHTEMPLATE_LT_VERSION/g"  $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_LAUNCHTEMPLATE_1_INSTANCE_TYPE/$SPOTFLEET_LAUNCHTEMPLATE_1_INSTANCE_TYPE/g"  $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_LAUNCHTEMPLATE_2_INSTANCE_TYPE/$SPOTFLEET_LAUNCHTEMPLATE_2_INSTANCE_TYPE/g"  $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_LAUNCHTEMPLATE_3_INSTANCE_TYPE/$SPOTFLEET_LAUNCHTEMPLATE_3_INSTANCE_TYPE/g"  $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE

sed -i "s/TMPL_SPOTFLEET_LAUNCHTEMPLATE_SUBNETS_1/$SPOTFLEET_LAUNCHTEMPLATE_SUBNETS_1/g" $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_LAUNCHTEMPLATE_SUBNETS_2/$SPOTFLEET_LAUNCHTEMPLATE_SUBNETS_2/g"  $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_SPOTFLEET_LAUNCHTEMPLATE_SUBNETS_3/$SPOTFLEET_LAUNCHTEMPLATE_SUBNETS_3/g" $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE


echo "Creating the Spot Fleet  using $SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE..."

#SPOT_FLEET_REQUEST_ID=$(aws ec2 request-spot-fleet --spot-fleet-request-config file://$SPOTFLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE|jq -r '.SpotFleetRequestId')

echo "Created the Spot Fleet (using launch template) request id $SPOT_FLEET_REQUEST_ID"


EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_FILE=ec2_fleet_generic_template_workshop2.json
EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE=ec2_fleet_generic_template_workshop2_temp.json
cp -Rfp $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_FILE $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE

echo "Populating EC2 Fleet configuration for in $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE"

EC2FLEET_SPOT_ALLOCATIION_STRATEGY=lowestPrice
EC2FLEET_SPOT_TERMINATE_BEHAVIOUR=terminate
EC2FLEET_SPOT_INSTANCE_POOL_COUNT=2
EC2FLEET_SPOT_MIN_TARGET_CAPACITY=2

EC2FLEET_OD_ALLOCATIION_STRATEGY=lowest-price
EC2FLEET_OD_MIN_TARGET_CAPACITY=1
EC2FLEET_TOTAL_TARGET_CAPACITY=3
EC2FLEET_SPOT_TARGET_CAPACITY=2
EC2FLEET_OD_TARGET_CAPACITY=1
EC2FLEET_LAUNCHTEMPLATE_LT_ID=$LAUCH_TEMPLATE_ID
EC2FLEET_LAUNCHTEMPLATE_LT_VERSION=$LAUNCH_TEMPLATE_VERSION



EC2FLEET_LAUNCHTEMPLATE_1_INSTANCE_TYPE=c3.large
EC2FLEET_LAUNCHTEMPLATE_2_INSTANCE_TYPE=t3a.medium
EC2FLEET_LAUNCHTEMPLATE_3_INSTANCE_TYPE=t3.medium

EC2FLEET_LAUNCHTEMPLATE_SUBNETS_1=subnet-764d7d11
EC2FLEET_LAUNCHTEMPLATE_SUBNETS_2=subnet-a2c2fd8c
EC2FLEET_LAUNCHTEMPLATE_SUBNETS_3=subnet-cb26e686

EC2FLEET_INSTANCESPEC_KEY_PAIR=awsajp_keypair


sed -i "s/TMPL_EC2FLEET_SPOT_ALLOCATIION_STRATEGY/$EC2FLEET_SPOT_ALLOCATIION_STRATEGY/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_SPOT_TERMINATE_BEHAVIOUR/$EC2FLEET_SPOT_TERMINATE_BEHAVIOUR/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_SPOT_INSTANCE_POOL_COUNT/$EC2FLEET_SPOT_INSTANCE_POOL_COUNT/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_SPOT_MIN_TARGET_CAPACITY/$EC2FLEET_SPOT_MIN_TARGET_CAPACITY/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE

sed -i "s/TMPL_EC2FLEET_OD_ALLOCATIION_STRATEGY/$EC2FLEET_OD_ALLOCATIION_STRATEGY/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_OD_MIN_TARGET_CAPACITY/$EC2FLEET_OD_MIN_TARGET_CAPACITY/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_LAUNCHTEMPLATE_LT_ID/$EC2FLEET_LAUNCHTEMPLATE_LT_ID/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_LAUNCHTEMPLATE_LT_VERSION/$EC2FLEET_LAUNCHTEMPLATE_LT_VERSION/g"  $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_LAUNCHTEMPLATE_1_INSTANCE_TYPE/$EC2FLEET_LAUNCHTEMPLATE_1_INSTANCE_TYPE/g"  $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE

sed -i "s/TMPL_EC2FLEET_TOTAL_TARGET_CAPACITY/$EC2FLEET_TOTAL_TARGET_CAPACITY/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_OD_TARGET_CAPACITY/$EC2FLEET_OD_TARGET_CAPACITY/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_SPOT_TARGET_CAPACITY/$EC2FLEET_SPOT_TARGET_CAPACITY/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_LAUNCHTEMPLATE_SUBNETS_1/$EC2FLEET_LAUNCHTEMPLATE_SUBNETS_1/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE

sed -i "s/TMPL_LAUNCH_TEMPLATE_NAME/$LAUNCH_TEMPLATE_NAME/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE



sed -i "s/TMPL_EC2FLEET_LAUNCHTEMPLATE_2_INSTANCE_TYPE/$EC2FLEET_LAUNCHTEMPLATE_2_INSTANCE_TYPE/g"  $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_LAUNCHTEMPLATE_3_INSTANCE_TYPE/$EC2FLEET_LAUNCHTEMPLATE_3_INSTANCE_TYPE/g"  $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE


sed -i "s/TMPL_EC2FLEET_LAUNCHTEMPLATE_SUBNETS_2/$EC2FLEET_LAUNCHTEMPLATE_SUBNETS_2/g"  $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE
sed -i "s/TMPL_EC2FLEET_LAUNCHTEMPLATE_SUBNETS_3/$EC2FLEET_LAUNCHTEMPLATE_SUBNETS_3/g" $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE


echo "Creating the Ec2 Fleet  using $EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE..."

#EC2_FLEET_REQUEST_ID=$(aws ec2 create-fleet --cli-input-json file://$EC2FLEET_TEMPLATE_LAUNCHTEMPLATE_TEMP_FILE)

EC2_FLEET_REQUEST_ID=$(aws ec2 create-fleet --launch-template-configs LaunchTemplateSpecification="{LaunchTemplateName=$LAUNCH_TEMPLATE_NAME,Version=1}" --target-capacity-specification TotalTargetCapacity=4,OnDemandTargetCapacity=1,DefaultTargetCapacityType=spot|jq -r '.FleetId')

echo "Created the Ec2 Fleet (using launch template) request id $EC2_FLEET_REQUEST_ID"






