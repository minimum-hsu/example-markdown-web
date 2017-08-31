#!/bin/bash

# Error code:
#   0 - success
#   1 - wrong argument
#   2 - failed to run/start/create
#   3 - failed to check
#   4 - failed to terminate/stop/remove
#   5 - failed to find/list

# aws cli empty response
#   None - text
#   null - json

# Environment variable:
#   AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY


set -e


# AWS CLI
CLI='aws --output json --cli-connect-timeout 60 --color off'
REGIONS=("us-east-1" "us-east-2" "us-west-1" "us-west-2" "ca-central-1" "eu-west-1" "eu-central-1" "eu-west-2" "ap-northeast-1" "ap-northeast-2" "ap-southeast-1" "ap-southeast-2" "ap-south-1" "sa-east-1")

# flag
TIMESTAMP="$(date +"%Y%m%d%H%M%S")"
UNIXTIME="$(date +"%s")"
DATETIME="$(date -u)"

# file
MD='/data/ec2/list.md'


# Description:
#   print string to stderr
# Param:
#   $@ - string
# Example:
#   echo_error "print to stderr"
echo_error() {
    echo "$@" 1>&2
}


# Description:
#   print data to specified file in markdown
# Param:
#   $1 - cli
#   $2 - output file
# Example:
#   list_instance $CLI_AP_NE_2 $MD
list_instance() {
    cli="$1"

    data=$(
       $cli \
       ec2 describe-instances \
       --query 'Reservations'
    )

    echo $data \
        | jq -r '.[].Instances[]
            | .Placement.AvailabilityZone
            + "|" + .InstanceId
            + "|" + (.Tags[]? | select(.Key == "Name") | .Value)
            + "|" + .PublicIpAddress
            + "|" + .LaunchTime
            + "|" + .KeyName
            + "|" + .State.Name
            + "|" + ([.Tags | map(.)? | .[] | .Key + " = " + .Value ] | join("<br />"))' \
        >> "$MD"
}


# Description:
#   reset files
reset() {
    d=$(dirname "$MD")
    mkdir -p $d
    rm -f "$MD"
    cat <<EOF >> "$MD"
# API server
Zone | Instance ID | Name | IP | Launch Time | Key Pair | State | Tags
--- | --- | --- | --- | --- | --- | --- | ---
EOF
}


# Description
stamp() {
    cat <<EOF >> "$MD"

### Last update
$DATETIME
EOF
}


# workflow
reset
for region in "${REGIONS[@]}"
do
    list_instance "$CLI --region $region"
done
stamp
