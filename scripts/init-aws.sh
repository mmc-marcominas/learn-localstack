#!/usr/bin/env bash

set -eou pipefail

create_queue_with_dlq() {
    local QUEUE_NAME=$1

    aws --endpoint-url=http://localstack:4566 sqs create-queue --queue-name ${QUEUE_NAME} --region us-east-1
    aws --endpoint-url=http://localstack:4566 sqs create-queue --queue-name ${QUEUE_NAME}-dlq --region us-east-1
    aws --endpoint-url=http://localstack:4566 sqs set-queue-attributes --region us-east-1 \
        --queue-url http://localstack:4566/000000000000/${QUEUE_NAME}-dlq \
        --attributes '{ "RedrivePolicy": " { \"deadLetterTargetArn\" : \"arn:aws:sqs:us-east-1:000000000000:'${QUEUE_NAME}'-dlq\", \"maxReceiveCount\": \"3\" }" }'
}

create_queue_with_dlq "some-queue-with-dlq"

# create all queues of a "env" file - any line with a XXX_QUEUE_NAME=name-of-xxx-queue
# example: FIRST_QUEUE_NAME=first-queue
while read Q; do
    create_queue_with_dlq $Q
done <<< $(grep "QUEUE_NAME=" /tmp/env-settings | cut -d'=' -f2 | grep -v '^$' | grep -F -v ' ' )

# grep "QUEUE_NAME=" ./env-settings get any line with QUEUE_NAME on it
# | cut -d'=' -f2       -> get value after = sign
# | grep -v '^$'        -> ignore empty values
# | grep -F -v ' '      -> remove spaces
