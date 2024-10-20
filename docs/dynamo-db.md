# Adding DynamoDB feature

On [docker-compose file](../docker-compose.yml), change `SERVICES: 'sqs'` to `SERVICES: 'sqs,s3,dynamodb'` adding AWS S3 service.

## Useful commands

### Create a table

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb create-table --table-name localstack --key-schema AttributeName=id,KeyType=HASH --attribute-definitions AttributeName=id,AttributeType=S --billing-mode PAY_PER_REQUEST | jq
```

Expected result:
``` json
{
    "TableDescription": {
        "AttributeDefinitions": [
            {
                "AttributeName": "id",
                "AttributeType": "S"
            }
        ],
        "TableName": "localstack",
        "KeySchema": [
            {
                "AttributeName": "id",
                "KeyType": "HASH"
            }
        ],
        "TableStatus": "ACTIVE",
        "CreationDateTime": 1729453051.354,
        "ProvisionedThroughput": {
            "LastIncreaseDateTime": 0.0,
            "LastDecreaseDateTime": 0.0,
            "NumberOfDecreasesToday": 0,
            "ReadCapacityUnits": 0,
            "WriteCapacityUnits": 0
        },
        "TableSizeBytes": 0,
        "ItemCount": 0,
        "TableArn": "arn:aws:dynamodb:us-east-1:000000000000:table/localstack",
        "TableId": "2fedc682-4b5c-46fa-a1c6-d078b8379756",
        "BillingModeSummary": {
            "BillingMode": "PAY_PER_REQUEST",
            "LastUpdateToPayPerRequestDateTime": 1729453051.354
        }
    }
}
```

### List a table

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb list-tables | jq
```

Expected result:
``` json
{
    "TableNames": [
        "localstack"
    ]
}
```

### Put some items on table

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb put-item --table-name localstack --item '{"id":{"S":"foo"}}'

aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb put-item --table-name localstack --item '{"id":{"S":"bar"}}'
```

### Describe a table

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb describe-table --table-name localstack --query 'Table.ItemCount'
```

Expected result:
``` bash
2
```

### Scan a table

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb scan --table-name localstack | jq
```

Expected result:
``` json
{
    "Items": [
        {
            "id": {
                "S": "bar"
            }
        },
        {
            "id": {
                "S": "foo"
            }
        }
    ],
    "Count": 2,
    "ScannedCount": 2,
    "ConsumedCapacity": null
}
```

### Query a table

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 dynamodb get-item --table-name localstack --key '{"id": {"S": "bar"}}' | jq
```

Expected result:
``` json
{
    "Item": {
        "id": {
            "S": "bar"
        }
    }
}
```
