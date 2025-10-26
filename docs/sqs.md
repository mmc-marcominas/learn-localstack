# AWS SQS Service Guide

This guide demonstrates how to use Amazon SQS (Simple Queue Service) with LocalStack for reliable message queuing and processing.

## 🎯 Overview

Amazon SQS is a fully managed message queuing service that enables you to decouple and scale microservices, distributed systems, and serverless applications. This guide covers essential SQS operations including queue management, message handling, and dead letter queue (DLQ) configuration.

## 🚀 Getting Started

### Prerequisites

- LocalStack running with SQS service enabled
- AWS CLI configured for LocalStack (`awslocal` command)
- `jq` for JSON formatting (optional)

### Service Configuration

Ensure SQS is enabled in your `docker-compose.yml`:

```yaml
environment:
  SERVICES: 'sqs,s3,sns,dynamodb,kms,route53'
```

## 📋 Core Operations

### 1. Queue Management

#### List All Queues

```bash
awslocal sqs list-queues | jq
```

**Expected Response:**
```json
{
  "QueueUrls": [
    "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue",
    "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue-dlq",
    "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-notification-queue",
    "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-notification-queue-dlq"
  ]
}
```

### 2. Message Operations

#### Send a Message

Send a structured event message to a queue:

```bash
awslocal sqs send-message \
    --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue \
    --message-body '{
        "event_id": "'$(uuidgen)'",
        "event_time": "'$(date '+%Y-%m-%d %H:%M:%S')Z'",
        "data": {
            "user_id": 83411,
            "name": "John Doe",
            "status": "active"
        }
    }'
```

**Expected Response:**
```json
{
  "MD5OfMessageBody": "f6670c3f05cc39731753950d06db102b",
  "MessageId": "a59cf59d-daf9-4b3d-bdc1-fddf0d8467fb"
}
```

#### Receive Messages

Retrieve messages from a queue:

```bash
awslocal sqs receive-message \
    --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue
```

**Expected Response:**
```json
{
  "Messages": [
    {
      "MessageId": "a59cf59d-daf9-4b3d-bdc1-fddf0d8467fb",
      "ReceiptHandle": "YzhiNDJiZTMtYjllNC00MjkyLTk0OTctNWVkZDM4NTg5N2ZjIGFybjphd3M6c3FzOnVzLWVhc3QtMTowMDAwMDAwMDAwMDA6c29tZS1pbXBvcnRhbnQtcXVldWUgYTU5Y2Y1OWQtZGFmOS00YjNkLWJkYzEtZmRkZjBkODQ2N2ZiIDE3Mjk0NjE1MzEuNDUwMDgzMw==",
      "MD5OfBody": "f6670c3f05cc39731753950d06db102b",
      "Body": "{\"event_id\":\"f5076f25-95f2-4e05-ad6a-1d5504f4d70b\",\"event_time\":\"2024-10-20 18:57:20Z\",\"data\":{\"user_id\":83411,\"name\":\"John Doe\",\"status\":\"active\"}}"
    }
  ]
}
```

#### Delete Messages

After processing a message, delete it from the queue:

```bash
# Get the receipt handle
receipt_handle=$(awslocal sqs receive-message \
    --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue \
    | jq -r '.Messages[0].ReceiptHandle')

# Delete the message
awslocal sqs delete-message \
    --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue \
    --receipt-handle "$receipt_handle"
```

## 🔄 Dead Letter Queue (DLQ) Configuration

### Understanding DLQ Behavior

Our infrastructure automatically creates DLQ queues with a redrive policy (maxReceiveCount: 3). When a message fails processing multiple times, it's moved to the DLQ.

#### Test DLQ Functionality

1. **Send a message to the main queue:**
```bash
awslocal sqs send-message \
    --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue \
    --message-body "Test message for DLQ"
```

2. **Receive the message multiple times without deleting it:**
```bash
# Use visibility-timeout 0 to immediately make the message available again
awslocal sqs receive-message \
    --visibility-timeout 0 \
    --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue
```

3. **Check LocalStack logs for DLQ activity:**
```log
localstack-main  | 2024-10-20T22:15:23.079 DEBUG --- [et.reactor-0] l.services.sqs.models : de-queued message SqsMessage(id=dba8a8d9-b9b9-4709-883e-d4fbc1a0eae0,group=None) from arn:aws:sqs:us-east-1:000000000000:my-processing-queue
localstack-main  | 2024-10-20T22:15:23.079 DEBUG --- [et.reactor-0] l.services.sqs.models : message SqsMessage(id=dba8a8d9-b9b9-4709-883e-d4fbc1a0eae0,group=None) has been received 4 times, marking it for DLQ
```

4. **Retrieve the message from the DLQ:**
```bash
awslocal sqs receive-message \
    --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue-dlq
```

## 🔧 Advanced Operations

### Using HTTP API Directly

You can also interact with SQS using HTTP requests:

```bash
curl -H "Accept: application/json" \
    "http://sqs.us-east-1.localhost.localstack.cloud:4566/_aws/sqs/messages?QueueUrl=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue" \
    | jq
```

**Expected Response:**
```json
{
  "ReceiveMessageResponse": {
    "ReceiveMessageResult": {
      "Message": [
        {
          "MessageId": "2a4ded21-598a-4f6b-8045-92125a5a1771",
          "MD5OfBody": "74a01a1f990e739151a2bf4f530e49f3",
          "Body": "{\"event_id\":\"e13dcbda-1ad4-46c6-9092-a9d6c31e573b\",\"event_time\":\"2024-10-20 19:40:55Z\",\"data\":{\"user_id\":83411,\"name\":\"John Doe\",\"status\":\"active\"}}",
          "Attribute": [
            {
              "Name": "SenderId",
              "Value": "000000000000"
            },
            {
              "Name": "SentTimestamp",
              "Value": "1729464055643"
            },
            {
              "Name": "ApproximateReceiveCount",
              "Value": "0"
            },
            {
              "Name": "ApproximateFirstReceiveTimestamp",
              "Value": "0"
            }
          ],
          "ReceiptHandle": "SQS/BACKDOOR/ACCESS"
        }
      ]
    },
    "ResponseMetadata": {
      "RequestId": "b8583c46-99ea-48b6-8cd9-2b327d19d0c8"
    }
  }
}
```

### Message Attributes and Metadata

SQS provides useful message attributes:

- **SenderId**: AWS account ID that sent the message
- **SentTimestamp**: Time when the message was sent
- **ApproximateReceiveCount**: Number of times the message has been received
- **ApproximateFirstReceiveTimestamp**: Time when the message was first received

## ⚠️ Important Notes

### Message Visibility Timeout

- Messages become invisible after being received
- Default visibility timeout is 30 seconds
- Use `--visibility-timeout 0` for immediate reprocessing (testing only)

### Message Ordering

- Standard SQS queues provide best-effort ordering
- For strict ordering, consider FIFO queues
- Messages may be delivered out of order

### DLQ Behavior

- Messages are moved to DLQ after `maxReceiveCount` failed attempts
- Our configuration sets `maxReceiveCount` to 3
- DLQ queues are automatically created with `-dlq` suffix

## 📚 Additional Resources

- [AWS SQS Documentation](https://docs.aws.amazon.com/sqs/)
- [LocalStack SQS Guide](https://docs.localstack.cloud/user-guide/aws/sqs/)
- [SQS Best Practices](https://docs.aws.amazon.com/sqs/latest/dg/sqs-best-practices.html)
