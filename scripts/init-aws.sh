#!/usr/bin/env bash

set -eou pipefail

# Function to generate ARN for an SQS queue
get_arn() {
    local ARN_TYPE=$1
    echo "arn:aws:${ARN_TYPE}:us-east-1:000000000000"
}

TOPIC_ARN=$(get_arn sns)
QUEUE_ARN=$(get_arn sqs)

create_queue_with_dlq() {
    local QUEUE_NAME=$1
    
    awslocal sqs create-queue --queue-name ${QUEUE_NAME} --region us-east-1
    awslocal sqs create-queue --queue-name ${QUEUE_NAME}-dlq --region us-east-1
    awslocal sqs set-queue-attributes --region us-east-1 \
        --queue-url http://localstack:4566/000000000000/${QUEUE_NAME} \
        --attributes '{ "RedrivePolicy": " { \"deadLetterTargetArn\" : \"'${QUEUE_ARN}':'${QUEUE_NAME}'-dlq\", \"maxReceiveCount\": \"3\" }" }'
}

create_bucket() {
    local BUCKET_NAME=$1

    awslocal s3api create-bucket --bucket ${BUCKET_NAME} --region us-east-1
}

create_topic() {
    local TOPIC_NAME=$1

    awslocal sns create-topic --name ${TOPIC_NAME} --region us-east-1
}

create_topic_subscription() {
    local TOPIC_NAME=$1
    local QUEUE_NAME=$2
    local FILTER_POLICY=$3

    local PROTOCOL="sqs"
    local TOPIC_INFO=${TOPIC_ARN}':'${TOPIC_NAME}
    local QUEUE_INFO=${QUEUE_ARN}':'${QUEUE_NAME}

    local SUBSCRIPTION=$(awslocal sns subscribe \
        --topic-arn "$TOPIC_INFO" \
        --protocol "$PROTOCOL" \
        --notification-endpoint "$QUEUE_INFO" \
        --region "us-east-1")

    local SUBSCRIPTION_ARN=$(echo "$SUBSCRIPTION" | grep -o '"SubscriptionArn": *"[^"]*"' | sed 's/.*: *"\(.*\)"/\1/')

    if [[ -n "$FILTER_POLICY" ]]; then
        awslocal sns set-subscription-attributes \
            --subscription-arn "$SUBSCRIPTION_ARN" \
            --attribute-name FilterPolicy \
            --attribute-value "$FILTER_POLICY" \
            --region "us-east-1"
    fi
}

# you can create a queues with dlq adding lines as follow:
create_queue_with_dlq "some-important-queue"

# create all queues of a "env" file - any line with a XXX_QUEUE_NAME=name-of-xxx-queue
# example: FIRST_QUEUE_NAME=first-queue
while read Q; do
    create_queue_with_dlq $Q
done <<< $(grep "QUEUE_NAME=" /tmp/env-settings | cut -d'=' -f2 | grep -v '^$' | grep -F -v ' ' )

# grep "QUEUE_NAME=" ./env-settings get any line with QUEUE_NAME on it
# | cut -d'=' -f2       -> get value after = sign
# | grep -v '^$'        -> ignore empty values
# | grep -F -v ' '      -> remove spaces

# you can create a buckets with dlq adding lines as follow:
create_bucket "some-important-bucket"

# create all buckets of a "env" file - any line with a BUCKET_NAME=name-of-xxx-bucket
# example: BUCKET_NAME=first-bucket
while read B; do
    create_bucket $B
done <<< $(grep "BUCKET_NAME=" /tmp/env-settings | cut -d'=' -f2 | grep -v '^$' | grep -F -v ' ' )

# you can create a topics with dlq adding lines as follow:
create_topic "some-important-topic"

# create all topics of a "env" file - any line with a XXX_TOPIC_NAME=name-of-xxx-topic
# example: FIRST_TOPIC_NAME=first-topic
while read T; do
    create_topic $T
done <<< $(grep "TOPIC_NAME=" /tmp/env-settings | cut -d'=' -f2 | grep -v '^$' | grep -F -v ' ' )

# create all topics subscription of a "env" file - any line with a BUCKET_TOPIC_SUBSCRIPTIONNAME=name-of-xxx-subscription
# example: TOPIC_SUBSCRIPTION=first-topic=first-queue={ "eventType": ["first-event"] }
while read S; do
    TOPIC_NAME=$(echo $S | cut -d'|' -f1)
    QUEUE_NAME=$(echo $S | cut -d'|' -f2)
    FILTER_POLICY=$(echo $S | cut -d'|' -f3)

    create_topic_subscription ${TOPIC_NAME} ${QUEUE_NAME} "${FILTER_POLICY}"
done <<< $(grep "TOPIC_SUBSCRIPTION=" /tmp/env-settings | cut -d'=' -f 2-5 | grep -v '^$')

PREFIX="*******************************"
printf "\n${PREFIX}\nOperations summary\n${PREFIX}\n"

printf "\n${PREFIX}\nbuckets:\n"
awslocal s3api list-buckets

printf "\n${PREFIX}\nqueues:\n"
awslocal sqs list-queues

printf "\n${PREFIX}\ntopics:\n"
awslocal sns list-topics

printf "\n${PREFIX}\ntopics subscriptions:\n"
awslocal sns list-subscriptions

printf "\n${PREFIX}\ntopics subscriptions attributes:\n"
SUBSCRIPTIONS_ARN=$(awslocal sns list-subscriptions --query 'Subscriptions[*].SubscriptionArn' --output text)
for ARN in $SUBSCRIPTIONS_ARN; do
    ATTRS=$(awslocal sns get-subscription-attributes --subscription-arn "$ARN")
    printf "Subscription ARN attributes: ${ARN}\n${ATTRS}\n"
done
