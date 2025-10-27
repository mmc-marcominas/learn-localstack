# LocalStack Infrastructure Automation

A Docker-based LocalStack environment that automatically provisions AWS infrastructure components based on configuration files. This project enables rapid development and testing of AWS services locally with minimal setup.

## 🎯 Project Overview

This project provides an automated infrastructure-as-code solution for LocalStack, allowing developers to define their AWS resources in a simple configuration file and have them automatically provisioned when the LocalStack container starts.

### Key Features

- **⚙️ Configuration-Driven**: Define all infrastructure through a simple `env-settings` file
- **🚀 Zero-Configuration Setup**: Infrastructure is created automatically on container startup
- **🔄 Queue Creation with DLQ**: Automatically creates SQS queues with dead letter queues for reliable message processing
- **🪣 Bucket Creation**: Provisions S3 buckets for object storage
- **📢 Topic Creation with Subscriptions**: Sets up SNS topics with queue subscriptions and optional filter policies

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- `jq` (optional, for JSON formatting): `sudo apt install jq`

### 1. Configure Your Infrastructure

Edit the `env-settings` file to define your AWS resources:

```bash
# SQS Queues (automatically created with DLQ)
FIRST_QUEUE_NAME=my-processing-queue
SECOND_QUEUE_NAME=my-notification-queue

# S3 Buckets
FIRST_BUCKET_NAME=my-app-storage
SECOND_BUCKET_NAME=my-backup-storage

# SNS Topics
FIRST_TOPIC_NAME=my-event-topic

# Topic Subscriptions (format: topic|queue|filter_policy)
FIRST_TOPIC_SUBSCRIPTION=my-event-topic|my-processing-queue|{ "eventType": ["user-action"] }
SECOND_TOPIC_SUBSCRIPTION=my-event-topic|my-notification-queue|{ "eventType": ["system-alert"] }
THIRD_TOPIC_SUBSCRIPTION=my-event-topic|my-processing-queue
```

### 2. Start LocalStack

```bash
docker compose up
```

The infrastructure will be automatically created based on your `env-settings` configuration.

### 3. Verify Infrastructure

Check LocalStack status:
```bash
curl http://localhost:4566/_localstack/info | jq
```

View created resources:
```bash
# List all buckets
aws --endpoint-url=http://localhost:4566 --region us-east-1 s3api list-buckets

# List all queues
aws --endpoint-url=http://localhost:4566 --region us-east-1 sqs list-queues

# List all topics
aws --endpoint-url=http://localhost:4566 --region us-east-1 sns list-topics

# List all subscriptions
aws --endpoint-url=http://localhost:4566 --region us-east-1 sns list-subscriptions
```

## 📋 Configuration Reference

### Environment Settings Format

The `env-settings` file uses a simple key-value format to define AWS resources:

#### Queue Configuration
```bash
# Format: {PREFIX}_QUEUE_NAME={queue-name}
FIRST_QUEUE_NAME=my-processing-queue
SECOND_QUEUE_NAME=my-notification-queue
```

Each queue is automatically created with a corresponding dead letter queue (`{queue-name}-dlq`) and configured with a redrive policy (maxReceiveCount: 3).

#### Bucket Configuration
```bash
# Format: {PREFIX}_BUCKET_NAME={bucket-name}
FIRST_BUCKET_NAME=my-app-storage
SECOND_BUCKET_NAME=my-backup-storage
```

#### Topic Configuration
```bash
# Format: {PREFIX}_TOPIC_NAME={topic-name}
FIRST_TOPIC_NAME=my-event-topic
```

#### Topic Subscription Configuration
```bash
# Format: {PREFIX}_TOPIC_SUBSCRIPTION={topic-name}|{queue-name}|{filter-policy}
# Filter policy is optional - omit for no filtering
FIRST_TOPIC_SUBSCRIPTION=my-event-topic|my-processing-queue|{ "eventType": ["user-action"] }
SECOND_TOPIC_SUBSCRIPTION=my-event-topic|my-notification-queue|{ "eventType": ["system-alert"] }
THIRD_TOPIC_SUBSCRIPTION=my-event-topic|my-processing-queue
```

## 🔧 Advanced Usage

### Manual Resource Management

While the automated setup handles most use cases, you can also manually interact with the created resources:

#### SQS Operations
```bash
# Send a message to a queue
aws --endpoint-url=http://localhost:4566 --region us-east-1 sqs send-message --queue-url http://localhost:4566/000000000000/my-processing-queue --message-body "Hello World"

# Receive messages
aws --endpoint-url=http://localhost:4566 --region us-east-1 sqs receive-message --queue-url http://localhost:4566/000000000000/my-processing-queue

# Check DLQ for failed messages
aws --endpoint-url=http://localhost:4566 --region us-east-1 sqs receive-message --queue-url http://localhost:4566/000000000000/my-processing-queue-dlq
```

#### S3 Operations
```bash
# Upload a file
aws --endpoint-url=http://localhost:4566 --region us-east-1 s3 cp ./env-settings s3://some-important-bucket/

# List bucket contents
aws --endpoint-url=http://localhost:4566 --region us-east-1 s3 ls s3://some-important-bucket/

# Generate signed URL
aws --endpoint-url=http://localhost:4566 --region us-east-1 s3 presign s3://some-important-bucket/env-settings
```

#### SNS Operations
```bash
# Publish a message to a topic
aws --endpoint-url=http://localhost:4566 --region us-east-1 sns publish --topic-arn arn:aws:sns:us-east-1:000000000000:some-important-topic --message "Test message"

# Publish with message attributes (for filtering)
aws --endpoint-url=http://localhost:4566 --region us-east-1 sns publish --topic-arn arn:aws:sns:us-east-1:000000000000:some-important-topic --message "User action" --message-attributes '{"eventType":{"DataType":"String","StringValue":"user-action"}}'
```

## 📚 Additional Resources

For detailed examples and advanced configurations, refer to the documentation:

- [S3 Service Documentation](./docs/s3.md) - Object storage operations
- [SQS Service Documentation](./docs/sqs.md) - Message queue operations  
- [SNS Service Documentation](./docs/sns.md) - Pub/sub messaging
- [DynamoDB Documentation](./docs/dynamo-db.md) - NoSQL database operations
- [KMS Documentation](./docs/kms-md) - Key management service
- [Route 53 Documentation](./docs/route-53.md) - DNS service
- [Initialization Details](./docs/init.md) - Technical implementation details

## 🛠️ Development

### Project Structure
```
├── docker-compose.yml          # LocalStack container configuration
├── env-settings               # Infrastructure configuration file
├── scripts/
│   └── init-aws.sh           # Automated infrastructure provisioning script
├── docs/                     # Service-specific documentation
└── volume/                   # LocalStack persistent data
```

### Customization

To extend the infrastructure automation:

1. Modify `scripts/init-aws.sh` to add new resource types
2. Update `env-settings` format documentation
3. Add corresponding configuration parsing logic

## 🤝 Contributing

This project serves as a learning experience with LocalStack. Feel free to:

- Add new AWS service configurations
- Improve the automation scripts
- Enhance documentation
- Share your use cases and improvements
