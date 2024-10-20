# Using AWS SQS

This [documentation](https://docs.localstack.cloud/user-guide/aws/sqs/) was used as reference.

## List queues

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sqs list-queues | jq
```

Expected result:
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

## Send a message

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sqs send-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/some-important-queue --message-body "{ 'event_id': '$(uuidgen)', 'event_time': '$(date '+%Y-%m-%d %H:%M:%S')Z', 'data': { 'some-id': 83411, 'name': 'Marco Minas', 'status': 'active' } }" | jq
```

Expected result:
``` json
{
  "MD5OfMessageBody": "f6670c3f05cc39731753950d06db102b",
  "MessageId": "a59cf59d-daf9-4b3d-bdc1-fddf0d8467fb"
}
```

## Receive sent message

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1  sqs receive-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/some-important-queue | jq
```

Expected result:
``` json
{
  "Messages": [
    {
      "MessageId": "a59cf59d-daf9-4b3d-bdc1-fddf0d8467fb",
      "ReceiptHandle": "YzhiNDJiZTMtYjllNC00MjkyLTk0OTctNWVkZDM4NTg5N2ZjIGFybjphd3M6c3FzOnVzLWVhc3QtMTowMDAwMDAwMDAwMDA6c29tZS1pbXBvcnRhbnQtcXVldWUgYTU5Y2Y1OWQtZGFmOS00YjNkLWJkYzEtZmRkZjBkODQ2N2ZiIDE3Mjk0NjE1MzEuNDUwMDgzMw==",
      "MD5OfBody": "f6670c3f05cc39731753950d06db102b",
      "Body": "{ 'event_id': 'f5076f25-95f2-4e05-ad6a-1d5504f4d70b', 'event_time': '2024-10-20 18:57:20Z', 'data': { 'some-id': 83411, 'name': 'Marco Minas', 'status': 'active' } }"
    }
  ]
}
```

## Delete sent message

### Get message ReceiptHandle

``` bash
receipt_handle=$(aws --endpoint-url=http://localhost:4566 --region us-east-1  sqs receive-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/some-important-queue | jq -r '.Messages[0].ReceiptHandle') && echo $receipt_handle
```

### Delete message of retrieved ReceiptHandle

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1  sqs delete-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/some-important-queue --receipt-handle $receipt_handle
```

## Validate DLQ queue configuration

Create a message on a queue with SQL attribute.

Retrieve this message N + 1 times according `maxReceiveCount` attribute using `--visibility-timeout 0` param to avoid wait to next read attempt:

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1  sqs receive-message --visibility-timeout 0 --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/some-important-queue | jq
```

Check Localstack log and you will see something like:

``` log
localstack-main  | 2024-10-20T22:15:23.079 DEBUG --- [et.reactor-0] l.services.sqs.models      : de-queued message SqsMessage(id=dba8a8d9-b9b9-4709-883e-d4fbc1a0eae0,group=None) from arn:aws:sqs:us-east-1:000000000000:some-important-queue
localstack-main  | 2024-10-20T22:15:23.079 DEBUG --- [et.reactor-0] l.services.sqs.models      : message SqsMessage(id=dba8a8d9-b9b9-4709-883e-d4fbc1a0eae0,group=None) has been received 4 times, marking it for DLQ
localstack-main  | 2024-10-20T22:15:23.080  INFO --- [et.reactor-0] localstack.request.aws     : AWS sqs.ReceiveMessage => 200
```

In this case, `SqsMessage (id:...) has been received 4 times, marking it for DLQ` indicates that queue `maxReceiveCount` is 3.

You can try read message and no message will be returned. Now, try read messages of `some-important-queue-dql` queue.

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1  sqs receive-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/some-important-queue-dlq | jq
```

## List messages with curl

``` bash
 curl -H "Accept: application/json" "http://sqs.us-east-1.localhost.localstack.cloud:4566/_aws/sqs/messages?QueueUrl=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/some-important-queue" | jq
 ```

Expected result:

 ``` json
 {
  "ReceiveMessageResponse": {
    "ReceiveMessageResult": {
      "Message": [
        {
          "MessageId": "2a4ded21-598a-4f6b-8045-92125a5a1771",
          "MD5OfBody": "74a01a1f990e739151a2bf4f530e49f3",
          "Body": "{ 'event_id': 'e13dcbda-1ad4-46c6-9092-a9d6c31e573b', 'event_time': '2024-10-20 19:40:55Z', 'data': { 'some-id': 83411, 'name': 'Marco Minas', 'status': 'active' } }",
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
        },
        {
          "MessageId": "3d8fe170-5394-4941-9464-672d6430af82",
          "MD5OfBody": "38c79369eed36b7dbc9d1a515fedc927",
          "Body": "{ 'event_id': '571279c8-e7c4-47b7-ad28-50addf5b7eec', 'event_time': '2024-10-20 19:40:58Z', 'data': { 'some-id': 83411, 'name': 'Marco Minas', 'status': 'active' } }",
          "Attribute": [
            {
              "Name": "SenderId",
              "Value": "000000000000"
            },
            {
              "Name": "SentTimestamp",
              "Value": "1729464059448"
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
