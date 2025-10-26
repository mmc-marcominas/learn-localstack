# AWS DynamoDB Service Guide

This guide demonstrates how to use Amazon DynamoDB with LocalStack for NoSQL database operations and data management.

## 🎯 Overview

Amazon DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability. This guide covers essential DynamoDB operations including table management, data operations, and querying.

## 🚀 Getting Started

### Prerequisites

- LocalStack running with DynamoDB service enabled
- AWS CLI configured for LocalStack (`awslocal` command)
- `jq` for JSON formatting (optional)

### Service Configuration

Ensure DynamoDB is enabled in your `docker-compose.yml`:

```yaml
environment:
  SERVICES: 'sqs,s3,sns,dynamodb,kms,route53'
```

## 📋 Core Operations

### 1. Table Management

#### Create a Table

Create a DynamoDB table with a primary key:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb create-table \
    --table-name my-app-data \
    --key-schema AttributeName=id,KeyType=HASH \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --billing-mode PAY_PER_REQUEST | jq
```

**Expected Response:**
```json
{
  "TableDescription": {
    "AttributeDefinitions": [
      {
        "AttributeName": "id",
        "AttributeType": "S"
      }
    ],
    "TableName": "my-app-data",
    "KeySchema": [
      {
        "AttributeName": "id",
        "KeyType": "HASH"
      }
    ],
    "TableStatus": "ACTIVE",
    "CreationDateTime": "2025-10-26T18:15:01.870000-03:00",
    "ProvisionedThroughput": {
      "LastIncreaseDateTime": "1969-12-31T21:00:00-03:00",
      "LastDecreaseDateTime": "1969-12-31T21:00:00-03:00",
      "NumberOfDecreasesToday": 0,
      "ReadCapacityUnits": 0,
      "WriteCapacityUnits": 0
    },
    "TableSizeBytes": 0,
    "ItemCount": 0,
    "TableArn": "arn:aws:dynamodb:us-east-1:000000000000:table/my-app-data",
    "TableId": "df7c8b65-756d-4fc1-83e3-072100302dd1",
    "BillingModeSummary": {
      "BillingMode": "PAY_PER_REQUEST",
      "LastUpdateToPayPerRequestDateTime": "2025-10-26T18:15:01.870000-03:00"
    },
    "DeletionProtectionEnabled": false
  }
}
```

#### List All Tables

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb list-tables | jq
```

**Expected Response:**
```json
{
    "TableNames": [
        "my-app-data"
    ]
}
```

#### Describe Table Details

Get comprehensive information about a table:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb describe-table --table-name my-app-data | jq
```

### 2. Data Operations

#### Insert Items

Add individual items to the table:

```bash
# Insert a simple item
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb put-item \
    --table-name my-app-data \
    --item '{
        "id": {"S": "user-001"},
        "name": {"S": "John Doe"},
        "email": {"S": "john@example.com"},
        "data_status": {"S": "active"},
        "created_at": {"S": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}
    }'

# Insert another item
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb put-item \
    --table-name my-app-data \
    --item '{
        "id": {"S": "user-002"},
        "name": {"S": "Jane Smith"},
        "email": {"S": "jane@example.com"},
        "data_status": {"S": "inactive"},
        "created_at": {"S": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}
    }'
```

#### Insert Complex Items

Add items with nested data structures:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb put-item \
    --table-name my-app-data \
    --item '{
        "id": {"S": "user-003"},
        "name": {"S": "Bob Johnson"},
        "email": {"S": "bob@example.com"},
        "data_status": {"S": "active"},
        "profile": {
            "M": {
                "age": {"N": "30"},
                "location": {"S": "New York"},
                "preferences": {
                    "M": {
                        "theme": {"S": "dark"},
                        "notifications": {"BOOL": true}
                    }
                }
            }
        },
        "tags": {"SS": ["developer", "premium", "beta-tester"]},
        "created_at": {"S": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}
    }'
```

### 3. Data Retrieval

#### Get Single Item

Retrieve a specific item by its primary key:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb get-item \
    --table-name my-app-data \
    --key '{"id": {"S": "user-001"}}' \
    | jq
```

**Expected Response:**
```json
{
    "Item": {
        "id": {"S": "user-001"},
        "name": {"S": "John Doe"},
        "email": {"S": "john@example.com"},
        "data_status": {"S": "active"},
        "created_at": {"S": "2024-10-20T18:47:02Z"}
    }
}
```

#### Scan Table

Retrieve all items from the table:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb scan --table-name my-app-data | jq
```

**Expected Response:**
```json
{
    "Items": [
        {
            "id": {"S": "user-002"},
            "name": {"S": "Jane Smith"},
            "email": {"S": "jane@example.com"},
            "data_status": {"S": "inactive"},
            "created_at": {"S": "2024-10-20T18:47:02Z"}
        },
        {
            "id": {"S": "user-001"},
            "name": {"S": "John Doe"},
            "email": {"S": "john@example.com"},
            "data_status": {"S": "active"},
            "created_at": {"S": "2024-10-20T18:47:02Z"}
        },
        {
            "id": {"S": "user-003"},
            "name": {"S": "Bob Johnson"},
            "email": {"S": "bob@example.com"},
            "data_status": {"S": "active"},
            "profile": {
                "M": {
                    "age": {"N": "30"},
                    "location": {"S": "New York"},
                    "preferences": {
                        "M": {
                            "theme": {"S": "dark"},
                            "notifications": {"BOOL": true}
                        }
                    }
                }
            },
            "tags": {"SS": ["developer", "premium", "beta-tester"]},
            "created_at": {"S": "2024-10-20T18:47:02Z"}
        }
    ],
    "Count": 3,
    "ScannedCount": 3,
    "ConsumedCapacity": null
}
```

### 4. Advanced Queries

#### Filter Expressions

Scan with filter conditions:

```bash
# Find all active users
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb scan \
    --table-name my-app-data \
    --filter-expression "data_status = :data_status" \
    --expression-attribute-values '{":data_status": {"S": "active"}}' \
    | jq
```

#### Projection Expressions

Retrieve only specific attributes:

```bash
# Get only id and email for all users
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb scan \
    --table-name my-app-data \
    --projection-expression "id, email" \
    | jq
```

#### Conditional Operations

Update items with conditions:

```bash
# Update user status only if current status is active
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb put-item \
    --table-name my-app-data \
    --item '{
        "id": {"S": "user-001"},
        "name": {"S": "John Doe"},
        "email": {"S": "john@example.com"},
        "data_status": {"S": "suspended"},
        "updated_at": {"S": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}
    }' \
    --condition-expression "data_status = :current_status" \
    --expression-attribute-values '{":current_status": {"S": "active"}}'
```

### 5. Table Statistics

#### Get Item Count

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb describe-table \
    --table-name my-app-data \
    --query 'Table.ItemCount'
```

**Expected Response:**
```bash
3
```

#### Get Table Size

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb describe-table \
    --table-name my-app-data \
    --query 'Table.TableSizeBytes'
```

## 🔧 Advanced Operations

### Batch Operations

#### Batch Write Items

Insert multiple items efficiently:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb batch-write-item \
    --request-items '{
        "my-app-data": [
            {
                "PutRequest": {
                    "Item": {
                        "id": {"S": "batch-001"},
                        "name": {"S": "Batch User 1"},
                        "data_status": {"S": "active"}
                    }
                }
            },
            {
                "PutRequest": {
                    "Item": {
                        "id": {"S": "batch-002"},
                        "name": {"S": "Batch User 2"},
                        "data_status": {"S": "active"}
                    }
                }
            }
        ]
    }'
```

#### Batch Get Items

Retrieve multiple items by their keys:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb batch-get-item \
    --request-items '{
        "my-app-data": {
            "Keys": [
                {"id": {"S": "user-001"}},
                {"id": {"S": "user-002"}}
            ]
        }
    }' \
    | jq
```

### Update Operations

#### Update Existing Items

Modify specific attributes:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb update-item \
    --table-name my-app-data \
    --key '{"id": {"S": "user-001"}}' \
    --update-expression "SET #data_status = :new_status, updated_at = :timestamp" \
    --expression-attribute-names '{"#data_status": "data_status"}' \
    --expression-attribute-values '{
        ":new_status": {"S": "inactive"},
        ":timestamp": {"S": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}
    }'
```

## ⚠️ Important Notes

### Data Types

DynamoDB uses specific data type notation:

- **S**: String
- **N**: Number
- **B**: Binary
- **BOOL**: Boolean
- **NULL**: Null
- **SS**: String Set
- **NS**: Number Set
- **BS**: Binary Set
- **L**: List
- **M**: Map

### Billing Modes

- **PAY_PER_REQUEST**: Pay only for what you use (recommended for development)
- **PROVISIONED**: Set read/write capacity units (for predictable workloads)

### Performance Considerations

- Use `scan` sparingly - it reads the entire table
- Prefer `get-item` for single item retrieval
- Use `query` for efficient access patterns with sort keys
- Consider using Global Secondary Indexes (GSI) for different access patterns

## 📚 Additional Resources

- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [LocalStack DynamoDB Guide](https://docs.localstack.cloud/user-guide/aws/dynamodb/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/dynamodb/latest/developerguide/best-practices.html)
