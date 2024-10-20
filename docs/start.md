# Loading a Localstack docker instance

When you do a `docker compose up` on a terminal, an instance of Localstack is started.

On stating logs you see something like this:

``` bash
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
```

Is important notice that `/etc/localstack/init/ready.d/init-aws.sh` execution was done. This script will apply any post starting command on it.

To understand what happened, [check this script file](../scripts/init-aws.sh) on `scripts`folder.

A summary about  this script is:

 - [x] a queue and a DLQ queue `some-important-queue` wil be created due `create_queue_with_dlq "some-important-queue"` line command. Also, `some-important-queue-dlq` will be applyed as DLQ queue of `some-important-queue`
 - [x] it will create one queue, one DLQ queue to each line of [env-settings file](../env-settings) containing `QUEUE_NAME=`
 - [x] also each DLQ queue QUEUE_NAME will be attributed to the correspondent queue QUEUE_NAME
