# AWS SNS Service Guide

This guide demonstrates how to use Amazon SNS (Simple Notification Service) with LocalStack for pub/sub messaging and event-driven architectures.

## 🎯 Overview

Amazon SNS is a fully managed pub/sub messaging service that enables you to decouple microservices, distributed systems, and serverless applications. This guide covers essential SNS operations including topic management, subscriptions, message publishing, and filter policies.

## 🚀 Getting Started

### Prerequisites

- LocalStack running with SNS service enabled
- AWS CLI configured for LocalStack (`awslocal` command)
- `jq` for JSON formatting (optional)

### Service Configuration

Ensure SNS is enabled in your `docker-compose.yml`:

```yaml
environment:
  SERVICES: 'sqs,s3,sns,dynamodb,kms,route53'
```

## 📋 Core Operations

### 1. Topic Management

#### List All Topics

```bash
awslocal sns list-topics | jq
```

**Expected Response:**
```json
{
  "Topics": [
    {
      "TopicArn": "arn:aws:sns:us-east-1:000000000000:my-event-topic"
    },
    {
      "TopicArn": "arn:aws:sns:us-east-1:000000000000:my-notification-topic"
    }
  ]
}
```

#### Get Topic Attributes

Retrieve detailed information about a topic:

```bash
awslocal sns get-topic-attributes \
    --topic-arn arn:aws:sns:us-east-1:000000000000:my-event-topic
```

**Expected Response:**
```json
{
  "Attributes": {
    "Owner": "000000000000",
    "Policy": "{\"Version\":\"2008-10-17\",\"Id\":\"__default_policy_ID\",\"Statement\":[{\"Effect\":\"Allow\",\"Sid\":\"__default_statement_ID\",\"Principal\":{\"AWS\":\"*\"},\"Action\":[\"SNS:GetTopicAttributes\",\"SNS:SetTopicAttributes\",\"SNS:AddPermission\",\"SNS:RemovePermission\",\"SNS:DeleteTopic\",\"SNS:Subscribe\",\"SNS:ListSubscriptionsByTopic\",\"SNS:Publish\"],\"Resource\":\"arn:aws:sns:us-east-1:000000000000:my-event-topic\",\"Condition\":{\"StringEquals\":{\"AWS:SourceOwner\":\"000000000000\"}}}]}",
    "TopicArn": "arn:aws:sns:us-east-1:000000000000:my-event-topic",
    "DisplayName": "",
    "SubscriptionsPending": "0",
    "SubscriptionsConfirmed": "1",
    "SubscriptionsDeleted": "0",
    "DeliveryPolicy": "",
    "EffectiveDeliveryPolicy": "{\"defaultHealthyRetryPolicy\": {\"numNoDelayRetries\": 0, \"numMinDelayRetries\": 0, \"minDelayTarget\": 20, \"maxDelayTarget\": 20, \"numMaxDelayRetries\": 0, \"numRetries\": 3, \"backoffFunction\": \"linear\"}, \"sicklyRetryPolicy\": null, \"throttlePolicy\": null, \"guaranteed\": false}"
  }
}
```

### 2. Subscription Management

#### Subscribe Queue to Topic

Create a subscription between a topic and an SQS queue:

```bash
awslocal sns subscribe \
    --topic-arn "arn:aws:sns:us-east-1:000000000000:my-event-topic" \
    --protocol sqs \
    --notification-endpoint "arn:aws:sqs:us-east-1:000000000000:my-processing-queue"
```

**Expected Response:**
```json
{
  "SubscriptionArn": "arn:aws:sns:us-east-1:000000000000:my-event-topic:e74ccf07-3fad-4a4e-b19d-3e95cc449823"
}
```

#### List All Subscriptions

```bash
awslocal sns list-subscriptions | jq
```

**Expected Response:**
```json
{
  "Subscriptions": [
    {
      "SubscriptionArn": "arn:aws:sns:us-east-1:000000000000:my-event-topic:e74ccf07-3fad-4a4e-b19d-3e95cc449823",
      "Owner": "000000000000",
      "Protocol": "sqs",
      "Endpoint": "arn:aws:sqs:us-east-1:000000000000:my-processing-queue",
      "TopicArn": "arn:aws:sns:us-east-1:000000000000:my-event-topic"
    }
  ]
}
```

#### Unsubscribe from Topic

```bash
awslocal sns unsubscribe \
    --subscription-arn "arn:aws:sns:us-east-1:000000000000:my-event-topic:e74ccf07-3fad-4a4e-b19d-3e95cc449823"
```

### 3. Message Publishing

#### Publish Basic Message

Send a message to all subscribers:

```bash
awslocal sns publish \
    --topic-arn arn:aws:sns:us-east-1:000000000000:my-event-topic \
    --message '{
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
  "MessageId": "6e44f066-d067-4b30-a645-6a67bb54b6b6"
}
```

#### Publish Message with Attributes

Send a message with attributes for filtering:

```bash
awslocal sns publish \
    --topic-arn arn:aws:sns:us-east-1:000000000000:my-event-topic \
    --message '{
        "event_id": "'$(uuidgen)'",
        "event_time": "'$(date '+%Y-%m-%d %H:%M:%S')Z'",
        "data": {
            "user_id": 83411,
            "name": "John Doe",
            "status": "active"
        }
    }' \
    --message-attributes '{
        "eventType": {
            "DataType": "String",
            "StringValue": "user-action"
        }
    }'
```

### 4. Message Consumption

#### Receive Messages from Subscribed Queue

After publishing to a topic, retrieve messages from subscribed queues:

```bash
awslocal sqs receive-message \
    --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/my-processing-queue
```

**Expected Response:**
```json
{
  "Messages": [
    {
      "MessageId": "bb3510a9-04b5-458b-9b0d-c83005e48c9b",
      "ReceiptHandle": "M2I3NWVhNGItYzkwOS00YjQ5LWEzOGItZDNjMTdmMmIxM2VjIGFybjphd3M6c3FzOnVzLWVhc3QtMTowMDAwMDAwMDAwMDA6c29tZS1pbXBvcnRhbnQtcXVldWUgYmIzNTEwYTktMDRiNS00NThiLTliMGQtYzgzMDA1ZTQ4YzliIDE3NjAzMDY1OTYuMjEwNjIxNA==",
      "MD5OfBody": "5f7f9144b04a339c33130f6130b7ceff",
      "Body": "{\"Type\": \"Notification\", \"MessageId\": \"309fe73d-bd1c-429b-bb18-606406ba0061\", \"TopicArn\": \"arn:aws:sns:us-east-1:000000000000:my-event-topic\", \"Message\": \"{\\\"event_id\\\":\\\"08f9d635-4691-4188-b25b-4cf92f4136fe\\\",\\\"event_time\\\":\\\"2025-10-12 19:02:43Z\\\",\\\"data\\\":{\\\"user_id\\\":83411,\\\"name\\\":\\\"John Doe\\\",\\\"status\\\":\\\"active\\\"}}\", \"Timestamp\": \"2025-10-12T22:02:43.693Z\", \"UnsubscribeURL\": \"http://localhost.localstack.cloud:4566/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:000000000000:my-event-topic:e74ccf07-3fad-4a4e-b19d-3e95cc449823\", \"SignatureVersion\": \"1\", \"Signature\": \"VMvYvE3/1o0e3a1X3J2Hx4HFMpAhNNZ82Ls25ryZelCQTXSdn7KwIyrZYwxJJ4ippskInWLEii5a4kJeKDUjd95mBikMhw0EbmxLgOvxuIcmNB214I+7imSSPKkM0RhpLuWgQHnE49Cx8o400u1EOTB8VGLh6ilzWOBvf5ea9I0/9ZmantXlHtwmm+9AVBQ15TsIUD0HA09JRPWCg3AkdNOJy1KIRYDMYxHHgKycf/liycu0mSJoAlLLlu+9DFWWCZT3ClMI/IqxD+evLL8YRfoqt3cjjcn6JRfzWKhVoe5nqA3MbS1pK5JB5uNg0dEG2oV6jDC502akD0EwCcV8Cg==\", \"SigningCertURL\": \"http://localhost.localstack.cloud:4566/_aws/sns/SimpleNotificationService-6c6f63616c737461636b69736e696365.pem\"}"
    }
  ]
}
```

## 🎯 Filter Policies

### Understanding Message Filtering

Filter policies allow you to route messages to specific subscribers based on message attributes. This enables selective message delivery and reduces unnecessary processing.

### Example Scenario

Consider a topic `my-event-topic` with three queue subscriptions:

1. **Queue 1**: `my-processing-queue` with filter `{ "eventType": ["user-action"] }`
2. **Queue 2**: `my-notification-queue` with filter `{ "eventType": ["system-alert"] }`
3. **Queue 3**: `my-backup-queue` with no filter (receives all messages)

#### Test Filter Policies

1. **Publish message without attributes:**
```bash
awslocal sns publish \
    --topic-arn arn:aws:sns:us-east-1:000000000000:my-event-topic \
    --message '{
        "event_id": "'$(uuidgen)'",
        "event_time": "'$(date '+%Y-%m-%d %H:%M:%S')Z'",
        "data": {
            "user_id": 83411,
            "name": "John Doe",
            "status": "active"
        }
    }'
```

**Result**: Only `my-backup-queue` receives the message (no filter = receives all).

2. **Publish message with `user-action` attribute:**
```bash
awslocal sns publish \
    --topic-arn arn:aws:sns:us-east-1:000000000000:my-event-topic \
    --message '{
        "event_id": "'$(uuidgen)'",
        "event_time": "'$(date '+%Y-%m-%d %H:%M:%S')Z'",
        "data": {
            "user_id": 83411,
            "name": "John Doe",
            "status": "active"
        }
    }' \
    --message-attributes '{
        "eventType": {
            "DataType": "String",
            "StringValue": "user-action"
        }
    }'
```

**Result**: Both `my-processing-queue` and `my-backup-queue` receive the message.

3. **Publish message with `system-alert` attribute:**
```bash
awslocal sns publish \
    --topic-arn arn:aws:sns:us-east-1:000000000000:my-event-topic \
    --message '{
        "event_id": "'$(uuidgen)'",
        "event_time": "'$(date '+%Y-%m-%d %H:%M:%S')Z'",
        "data": {
            "alert_level": "high",
            "message": "System maintenance required"
        }
    }' \
    --message-attributes '{
        "eventType": {
            "DataType": "String",
            "StringValue": "system-alert"
        }
    }'
```

**Result**: Both `my-notification-queue` and `my-backup-queue` receive the message.

## ⚠️ Important Notes

### Message ID Behavior

When publishing to SNS, you'll notice two different Message IDs:

- **Topic MessageId**: The ID returned when publishing to the topic
- **Queue MessageId**: The ID assigned when the message is delivered to the queue

This is normal behavior - the topic creates one message, and each queue delivery creates a new message with its own ID.

### Message Structure

SNS messages delivered to SQS queues are wrapped in a notification envelope:

```json
{
  "Type": "Notification",
  "MessageId": "topic-message-id",
  "TopicArn": "arn:aws:sns:us-east-1:000000000000:my-event-topic",
  "Message": "your-actual-message-content",
  "Timestamp": "2025-10-12T22:02:43.693Z",
  "UnsubscribeURL": "...",
  "SignatureVersion": "1",
  "Signature": "...",
  "SigningCertURL": "..."
}
```

### Filter Policy Syntax

Filter policies use JSON format with specific operators:

```json
{
  "eventType": ["user-action", "system-alert"],
  "priority": [{"numeric": [">=", 5]}],
  "environment": ["production"]
}
```

## 📚 Additional Resources

- [AWS SNS Documentation](https://docs.aws.amazon.com/sns/)
- [LocalStack SNS Guide](https://docs.localstack.cloud/user-guide/aws/sns/)
- [SNS Message Filtering](https://docs.aws.amazon.com/sns/latest/dg/sns-message-filtering.html)
