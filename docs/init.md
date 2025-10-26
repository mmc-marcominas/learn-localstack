# Loading a Localstack docker instance

When you do a `docker compose up` on a terminal, an instance of Localstack is started.

On stating logs you see something like this:

``` bash
...

localstack-main  | 2024-10-20T16:02:13.093 DEBUG --- [  MainThread] plux.runtime.manager       : loading plugin localstack.init.runner:sh
localstack-main  | 2024-10-20T16:02:13.094 DEBUG --- [  MainThread] localstack.runtime.init    : Init scripts discovered: {BOOT: [], START: [], READY: [Script(path='/etc/localstack/init/ready.d/init-aws.sh', stage=READY, state=UNKNOWN)], SHUTDOWN: []}

...

localstack-main  | 2024-10-20T16:02:22.447 DEBUG --- [et.reactor-0] l.services.sqs.provider    : creating queue key=third-queue attributes=None tags=None
localstack-main  | 2024-10-20T16:02:22.448  INFO --- [et.reactor-0] localstack.request.aws     : AWS sqs.CreateQueue => 200
localstack-main  | {
localstack-main  |     "QueueUrl": "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/third-queue"
localstack-main  | }
localstack-main  | 2024-10-20T16:02:23.253 DEBUG --- [et.reactor-0] l.services.sqs.provider    : creating queue key=third-queue-dlq attributes=None tags=None
localstack-main  | 2024-10-20T16:02:23.253  INFO --- [et.reactor-0] localstack.request.aws     : AWS sqs.CreateQueue => 200
localstack-main  | {
localstack-main  |     "QueueUrl": "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/third-queue-dlq"
localstack-main  | }
localstack-main  | 2024-10-20T16:02:24.006  INFO --- [et.reactor-0] localstack.request.aws     : AWS sqs.SetQueueAttributes => 200
localstack-main  | Ready.

...
```

Is important notice that `/etc/localstack/init/ready.d/init-aws.sh` execution was done. This script will apply any post starting command on it.

To understand what happened, [check this script file](../scripts/init-aws.sh) on `scripts`folder.

## Script initalization related to queues

A summary about this script related to queues is:

 - [x] a queue and a DLQ queue wil be created due `create_queue_with_dlq "some-important-queue"` script line command. Also, `some-important-queue-dlq` will be applyed as DLQ queue of `some-important-queue` queue
 - [x] it will create one queue and related DLQ queue to each line of [env-settings file](../env-settings) containing `QUEUE_NAME=`
 - [x] also each DLQ queue QUEUE_NAME will be attributed to the correspondent queue QUEUE_NAME

To check all created queues try:
``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sqs list-queues | jq
```

Expected result is something like this:
``` json
{
    "QueueUrls": [
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/some-important-queue",
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/some-important-queue-dlq",
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/first-queue",
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/first-queue-dlq",
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/second-queue",
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/second-queue-dlq",
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/third-queue",
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/third-queue-dlq"
    ]
}
```

## Script initalization related to buckets

On stating logs you see something like this:

``` bash
...

localstack-main  | 2025-10-26T17:17:40.024  INFO --- [et.reactor-0] localstack.request.aws     : AWS s3.CreateBucket => 200
localstack-main  | {
localstack-main  |     "Location": "/some-important-bucket"
localstack-main  | }
localstack-main  | 2025-10-26T17:17:40.707  INFO --- [et.reactor-0] localstack.request.aws     : AWS s3.CreateBucket => 200
localstack-main  | {
localstack-main  |     "Location": "/first-bucket"
localstack-main  | }
localstack-main  | 2025-10-26T17:17:41.345  INFO --- [et.reactor-0] localstack.request.aws     : AWS s3.CreateBucket => 200
localstack-main  | {
localstack-main  |     "Location": "/second-bucket"
localstack-main  | }

...

```

A summary about this script related to buckets is:


 - [x] a bucket `some-important-bucket` wil be created due `create_bucket "some-important-bucket"` script line command.
 - [x] it will create one bucket to each line of [env-settings file](../env-settings) containing `BUCKET_NAME=`

## Script initalization related to topics

On stating logs you see something like this:

``` bash
...

localstack-main  | 2025-10-26T17:17:42.465  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.CreateTopic => 200
localstack-main  | {
localstack-main  |     "TopicArn": "arn:aws:sns:us-east-1:000000000000:some-important-topic"
localstack-main  | }
localstack-main  | 2025-10-26T17:17:43.091  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.CreateTopic => 200
localstack-main  | {
localstack-main  |     "TopicArn": "arn:aws:sns:us-east-1:000000000000:first-topic"
localstack-main  | }

...

localstack-main  | 2025-10-26T17:17:43.709  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.Subscribe => 200
localstack-main  | 2025-10-26T17:17:44.316  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.SetSubscriptionAttributes => 200
localstack-main  | 2025-10-26T17:17:44.935  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.Subscribe => 200
localstack-main  | 2025-10-26T17:17:45.554  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.SetSubscriptionAttributes => 200
localstack-main  | 2025-10-26T17:17:46.167  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.Subscribe => 200

...

```

A summary about this script related to topics is:


 - [x] a topic `some-important-topic` wil be created due `create_topic "some-important-topic"` script line command.
 - [x] it will create one topic to each line of [env-settings file](../env-settings) containing `TOPIC_NAME=`
 - [x] it also create one subscription to each line of [env-settings file](../env-settings) containing `TOPIC_SUBSCRIPTION=`

Topic subscription can be done passing topic name, queue name and a optional json containing filter policy.

On [env-settings file](../env-settings) you can see this lines:

``` bash

FIRST_TOPIC_SUBSCRIPTION=first-topic|first-queue|{ "eventType": ["first-event"] }
SECOND_TOPIC_SUBSCRIPTION=first-topic|second-queue|{ "eventType": ["second-event"] }
THIRD_TOPIC_SUBSCRIPTION=first-topic|third-queue

```

That results in:

 - [x] subscribe `first-queue` on `first-topic` using `{ "eventType": ["first-event"] }` filter policy
 - [x] subscribe `second-queue` on `first-topic` using `{ "eventType": ["second-event"] }` filter policy
 - [x] subscribe `second-queue` on `third-topic` without filter policy

In other words:

 - [x] any message published on `first-topic` with an attribute `eventType` equal to `first-event` will be caught by `first-queue`
 - [x] any message published on `first-topic` with an attribute `eventType` equal to `second-event` will be caught by `second-queue`
 - [x] any message published on `first-topic` no matter it's attributes will be caught by `third-queue`

## Script initalization operations summary

After all creation infra, a summary indicates what was done:

 - [x] list of all created buckets
 - [x] list of all created queues
 - [x] list of all created topics
 - [x] list of all created topics subscriptions
