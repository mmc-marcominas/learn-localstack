# LocalStack Initialization Guide

This guide explains the automated infrastructure provisioning process that occurs when LocalStack starts up, including the initialization script execution and resource creation.

## 🎯 Overview

LocalStack automatically provisions AWS infrastructure based on configuration files when the container starts. This process is handled by the initialization script located at `/etc/localstack/init/ready.d/init-aws.sh`, which reads the `env-settings` file and creates the corresponding AWS resources.

## 🚀 Initialization Process

### Container Startup Sequence

When you run `docker compose up`, LocalStack follows this initialization sequence:

1. **Container Creation**: LocalStack container starts
2. **Service Discovery**: LocalStack detects available AWS services
3. **Script Discovery**: LocalStack finds initialization scripts
4. **Script Execution**: The `init-aws.sh` script runs automatically
5. **Resource Provisioning**: AWS resources are created based on configuration
6. **Ready State**: LocalStack becomes available for use

### Script Discovery Log

During startup, you'll see logs indicating script discovery:

```log
localstack-main  | 2024-10-20T16:02:13.093 DEBUG --- [  MainThread] plux.runtime.manager       : loading plugin localstack.init.runner:sh
localstack-main  | 2024-10-20T16:02:13.094 DEBUG --- [  MainThread] localstack.runtime.init    : Init scripts discovered: {BOOT: [], START: [], READY: [Script(path='/etc/localstack/init/ready.d/init-aws.sh', stage=READY, state=UNKNOWN)], SHUTDOWN: []}
```

The script is automatically executed when LocalStack reaches the READY state.

## 📋 Infrastructure Provisioning

### Queue Creation Process

The initialization script creates SQS queues with dead letter queues (DLQ) based on the `env-settings` configuration.

#### Queue Creation Logs

```log
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
```

#### Queue Configuration Summary

The script automatically:

- ✅ Creates a main queue for each `QUEUE_NAME` entry in `env-settings`
- ✅ Creates a corresponding DLQ with `-dlq` suffix
- ✅ Configures redrive policy with `maxReceiveCount: 3`
- ✅ Links the DLQ to the main queue

#### Verify Queue Creation

After initialization, verify all queues were created:

```bash
awslocal sqs list-queues | jq
```

**Expected Result:**
```json
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

### Bucket Creation Process

S3 buckets are created based on `BUCKET_NAME` entries in the configuration file.

#### Bucket Creation Logs

```log
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
```

#### Bucket Configuration Summary

The script automatically:

- ✅ Creates a bucket for each `BUCKET_NAME` entry in `env-settings`
- ✅ Uses the exact name specified in the configuration
- ✅ Sets up standard S3 bucket configuration

### Topic Creation Process

SNS topics are created based on `TOPIC_NAME` entries in the configuration file.

#### Topic Creation Logs

```log
localstack-main  | 2025-10-26T17:17:42.465  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.CreateTopic => 200
localstack-main  | {
localstack-main  |     "TopicArn": "arn:aws:sns:us-east-1:000000000000:some-important-topic"
localstack-main  | }
localstack-main  | 2025-10-26T17:17:43.091  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.CreateTopic => 200
localstack-main  | {
localstack-main  |     "TopicArn": "arn:aws:sns:us-east-1:000000000000:first-topic"
localstack-main  | }
```

#### Topic Subscription Process

Topic subscriptions are created based on `TOPIC_SUBSCRIPTION` entries with optional filter policies.

#### Subscription Creation Logs

```log
localstack-main  | 2025-10-26T17:17:43.709  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.Subscribe => 200
localstack-main  | 2025-10-26T17:17:44.316  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.SetSubscriptionAttributes => 200
localstack-main  | 2025-10-26T17:17:44.935  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.Subscribe => 200
localstack-main  | 2025-10-26T17:17:45.554  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.SetSubscriptionAttributes => 200
localstack-main  | 2025-10-26T17:17:46.167  INFO --- [et.reactor-0] localstack.request.aws     : AWS sns.Subscribe => 200
```

#### Topic Configuration Summary

The script automatically:

- ✅ Creates a topic for each `TOPIC_NAME` entry in `env-settings`
- ✅ Creates subscriptions for each `TOPIC_SUBSCRIPTION` entry
- ✅ Applies filter policies when specified
- ✅ Links topics to existing queues

### Configuration Format

The `env-settings` file uses a specific format for each resource type:

#### Queue Configuration
```bash
# Format: {PREFIX}_QUEUE_NAME={queue-name}
FIRST_QUEUE_NAME=first-queue
SECOND_QUEUE_NAME=second-queue
THIRD_QUEUE_NAME=third-queue
```

#### Bucket Configuration
```bash
# Format: {PREFIX}_BUCKET_NAME={bucket-name}
FIRST_BUCKET_NAME=first-bucket
SECOND_BUCKET_NAME=second-bucket
```

#### Topic Configuration
```bash
# Format: {PREFIX}_TOPIC_NAME={topic-name}
FIRST_TOPIC_NAME=first-topic
```

#### Topic Subscription Configuration
```bash
# Format: {PREFIX}_TOPIC_SUBSCRIPTION={topic-name}|{queue-name}|{filter-policy}
# Filter policy is optional
FIRST_TOPIC_SUBSCRIPTION=first-topic|first-queue|{ "eventType": ["first-event"] }
SECOND_TOPIC_SUBSCRIPTION=first-topic|second-queue|{ "eventType": ["second-event"] }
THIRD_TOPIC_SUBSCRIPTION=first-topic|third-queue
```

## 🔧 Initialization Script Details

### Script Location

The initialization script is located at:
- **Container Path**: `/etc/localstack/init/ready.d/init-aws.sh`
- **Host Path**: `./scripts/init-aws.sh`

### Script Functions

The script contains several key functions:

#### `create_queue_with_dlq(queue_name)`
- Creates a main SQS queue
- Creates a corresponding DLQ with `-dlq` suffix
- Configures redrive policy with `maxReceiveCount: 3`

#### `create_bucket(bucket_name)`
- Creates an S3 bucket
- Uses standard bucket configuration

#### `create_topic(topic_name)`
- Creates an SNS topic
- Sets up standard topic configuration

#### `create_topic_subscription(topic_name, queue_name, filter_policy)`
- Creates subscription between topic and queue
- Applies filter policy if provided
- Uses SQS protocol for queue subscriptions

### Script Execution Flow

1. **Parse Configuration**: Read and parse `env-settings` file
2. **Create Queues**: Process all `QUEUE_NAME` entries
3. **Create Buckets**: Process all `BUCKET_NAME` entries
4. **Create Topics**: Process all `TOPIC_NAME` entries
5. **Create Subscriptions**: Process all `TOPIC_SUBSCRIPTION` entries
6. **Summary Report**: Display created resources

## 📊 Initialization Summary

After successful initialization, the script displays a summary of all created resources:

### Summary Output

```bash
*******************************
Operations summary
*******************************

*******************************
buckets:
{
    "Buckets": [
        {
            "Name": "first-bucket",
            "CreationDate": "2024-10-20T18:47:02.000Z"
        },
        {
            "Name": "second-bucket",
            "CreationDate": "2024-10-20T18:47:02.000Z"
        }
    ]
}

*******************************
queues:
{
    "QueueUrls": [
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/first-queue",
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/first-queue-dlq",
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/second-queue",
        "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/second-queue-dlq"
    ]
}

*******************************
topics:
{
    "Topics": [
        {
            "TopicArn": "arn:aws:sns:us-east-1:000000000000:first-topic"
        }
    ]
}

*******************************
topics subscriptions:
{
    "Subscriptions": [
        {
            "SubscriptionArn": "arn:aws:sns:us-east-1:000000000000:first-topic:subscription-id",
            "Owner": "000000000000",
            "Protocol": "sqs",
            "Endpoint": "arn:aws:sqs:us-east-1:000000000000:first-queue",
            "TopicArn": "arn:aws:sns:us-east-1:000000000000:first-topic"
        }
    ]
}
```

## ⚠️ Important Notes

### Script Execution Timing

- The script runs automatically when LocalStack reaches the READY state
- No manual intervention is required
- Resources are created before LocalStack becomes available for use

### Configuration Validation

- Empty values are ignored (e.g., `SOME_QUEUE_NAME_WITHOUT_VALUE=`)
- Invalid entries are skipped
- The script continues processing even if individual operations fail

### Resource Dependencies

- Topics must be created before subscriptions
- Queues must exist before topic subscriptions
- The script handles these dependencies automatically

### Error Handling

- The script uses `set -eou pipefail` for error handling
- Failed operations are logged but don't stop the entire process
- Check LocalStack logs for detailed error information

## 🔍 Troubleshooting

### Common Issues

#### Script Not Executing
```bash
# Check if script exists in container
docker exec localstack-main ls -la /etc/localstack/init/ready.d/

# Check LocalStack logs for script discovery
docker logs localstack-main | grep "Init scripts discovered"
```

#### Resources Not Created
```bash
# Check script execution logs
docker logs localstack-main | grep "Operations summary"

# Verify env-settings file format
cat env-settings
```

#### Configuration Errors
```bash
# Check for syntax errors in env-settings
grep -v "^#" env-settings | grep -v "^$"

# Verify script can read the file
docker exec localstack-main cat /tmp/env-settings
```

## 📚 Additional Resources

- [LocalStack Initialization](https://docs.localstack.cloud/user-guide/aws/init-hooks/)
- [Script Configuration](https://docs.localstack.cloud/user-guide/aws/init-hooks/#script-configuration)
- [Initialization Scripts](https://docs.localstack.cloud/user-guide/aws/init-hooks/#initialization-scripts)