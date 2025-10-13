# Using AWS SNS

This [documentation](https://docs.localstack.cloud/user-guide/aws/sns/) was used as reference.

## List topics

``` bash
aws --endpoint-url=http://localhost:4566 sns list-topics --region us-east-1 | jq
```

Expected result:
``` json
{
  "Topics": [
    {
      "TopicArn": "arn:aws:sns:us-east-1:000000000000:some-important-topic"
    },
    {
      "TopicArn": "arn:aws:sns:us-east-1:000000000000:first-topic"
    }
  ]
}
```
## Get topic attributes


``` bash
aws --endpoint-url=http://localhost:4566 sns get-topic-attributes --topic-arn arn:aws:sns:us-east-1:000000000000:some-important-topic --region us-east-1 | jq
```

Expected result:
``` json
{
  "Attributes": {
    "Owner": "000000000000",
    "Policy": "{\"Version\":\"2008-10-17\",\"Id\":\"__default_policy_ID\",\"Statement\":[{\"Effect\":\"Allow\",\"Sid\":\"__default_statement_ID\",\"Principal\":{\"AWS\":\"*\"},\"Action\":[\"SNS:GetTopicAttributes\",\"SNS:SetTopicAttributes\",\"SNS:AddPermission\",\"SNS:RemovePermission\",\"SNS:DeleteTopic\",\"SNS:Subscribe\",\"SNS:ListSubscriptionsByTopic\",\"SNS:Publish\"],\"Resource\":\"arn:aws:sns:us-east-1:000000000000:some-important-topic\",\"Condition\":{\"StringEquals\":{\"AWS:SourceOwner\":\"000000000000\"}}}]}",
    "TopicArn": "arn:aws:sns:us-east-1:000000000000:some-important-topic",
    "DisplayName": "",
    "SubscriptionsPending": "0",
    "SubscriptionsConfirmed": "0",
    "SubscriptionsDeleted": "0",
    "DeliveryPolicy": "",
    "EffectiveDeliveryPolicy": "{\"defaultHealthyRetryPolicy\": {\"numNoDelayRetries\": 0, \"numMinDelayRetries\": 0, \"minDelayTarget\": 20, \"maxDelayTarget\": 20, \"numMaxDelayRetries\": 0, \"numRetries\": 3, \"backoffFunction\": \"linear\"}, \"sicklyRetryPolicy\": null, \"throttlePolicy\": null, \"guaranteed\": false}"
  }
}
```

## Subscribing in a SQS queue

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sns subscribe --topic-arn "arn:aws:sns:us-east-1:000000000000:some-important-topic" --protocol sqs --notification-endpoint "arn:aws:sqs:us-east-1:000000000000:some-important-queue" | jq
```

Expected result:
``` json
{
  "SubscriptionArn": "arn:aws:sns:us-east-1:000000000000:some-important-topic:e74ccf07-3fad-4a4e-b19d-3e95cc449823"
}
```

## List subscriptions

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sns list-subscriptions | jq
```

Expected result:
``` json
{
  "Subscriptions": [
    {
      "SubscriptionArn": "arn:aws:sns:us-east-1:000000000000:some-important-topic:e74ccf07-3fad-4a4e-b19d-3e95cc449823",
      "Owner": "000000000000",
      "Protocol": "sqs",
      "Endpoint": "arn:aws:sqs:us-east-1:000000000000:some-important-queue",
      "TopicArn": "arn:aws:sns:us-east-1:000000000000:some-important-topic"
    }
  ]
}
```

## Publish a message

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sns publish --topic-arn arn:aws:sns:us-east-1:000000000000:some-important-topic --message "{ 'event_id': '$(uuidgen)', 'event_time': '$(date '+%Y-%m-%d %H:%M:%S')Z', 'data': { 'some-id': 83411, 'name': 'Marco Minas', 'status': 'active' } }" | jq
```

Expected result:
``` json
{
  "MessageId": "6e44f066-d067-4b30-a645-6a67bb54b6b6"
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
      "MessageId": "bb3510a9-04b5-458b-9b0d-c83005e48c9b",
      "ReceiptHandle": "M2I3NWVhNGItYzkwOS00YjQ5LWEzOGItZDNjMTdmMmIxM2VjIGFybjphd3M6c3FzOnVzLWVhc3QtMTowMDAwMDAwMDAwMDA6c29tZS1pbXBvcnRhbnQtcXVldWUgYmIzNTEwYTktMDRiNS00NThiLTliMGQtYzgzMDA1ZTQ4YzliIDE3NjAzMDY1OTYuMjEwNjIxNA==",
      "MD5OfBody": "5f7f9144b04a339c33130f6130b7ceff",
      "Body": "{\"Type\": \"Notification\", \"MessageId\": \"309fe73d-bd1c-429b-bb18-606406ba0061\", \"TopicArn\": \"arn:aws:sns:us-east-1:000000000000:some-important-topic\", \"Message\": \"{ 'event_id': '08f9d635-4691-4188-b25b-4cf92f4136fe', 'event_time': '2025-10-12 19:02:43Z', 'data': { 'some-id': 83411, 'name': 'Marco Minas', 'status': 'active' } }\", \"Timestamp\": \"2025-10-12T22:02:43.693Z\", \"UnsubscribeURL\": \"http://localhost.localstack.cloud:4566/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:000000000000:some-important-topic:e74ccf07-3fad-4a4e-b19d-3e95cc449823\", \"SignatureVersion\": \"1\", \"Signature\": \"VMvYvE3/1o0e3a1X3J2Hx4HFMpAhNNZ82Ls25ryZelCQTXSdn7KwIyrZYwxJJ4ippskInWLEii5a4kJeKDUjd95mBikMhw0EbmxLgOvxuIcmNB214I+7imSSPKkM0RhpLuWgQHnE49Cx8o400u1EOTB8VGLh6ilzWOBvf5ea9I0/9ZmantXlHtwmm+9AVBQ15TsIUD0HA09JRPWCg3AkdNOJy1KIRYDMYxHHgKycf/liycu0mSJoAlLLlu+9DFWWCZT3ClMI/IqxD+evLL8YRfoqt3cjjcn6JRfzWKhVoe5nqA3MbS1pK5JB5uNg0dEG2oV6jDC502akD0EwCcV8Cg==\", \"SigningCertURL\": \"http://localhost.localstack.cloud:4566/_aws/sns/SimpleNotificationService-6c6f63616c737461636b69736e696365.pem\"}"
    }
  ]
}
```

## Topic unsubscription

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sns unsubscribe --subscription-arn "arn:aws:sns:us-east-1:000000000000:some-important-topic:e74ccf07-3fad-4a4e-b19d-3e95cc449823" | jq 
```

## Topic filter policy

Let's set a scenario: one topic, `first-topic', for example, and three queues with different subscription

 * queue `first-queue` subscribe topic using `{ "eventType": ["first-event"] }` as filter policy
 * queue `second-queue` subscribe topic using `{ "eventType": ["second-event"] }` as filter policy
 * queue `first-queue` subscribe topic without any filter policy

Then we will publhis a message on topic:
``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sns publish --topic-arn arn:aws:sns:us-east-1:000000000000:first-topic --message "{ 'event_id': '$(uuidgen)', 'event_time': '$(date '+%Y-%m-%d %H:%M:%S')Z', 'data': { 'some-id': 83411, 'name': 'Marco Minas', 'status': 'active' } }" | jq 
```

That will results:
``` json
{
  "MessageId": "5dc3350c-58ca-4b27-8730-914278bd7d88"
}
``` 

And then we will try to get message from first queues:
``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sqs receive-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/first-queue | jq
```

And it's result is nothing.

Then, second one:
``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sqs receive-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/second-queue | jq
```

Will it's result is nothing too.

And Then, third queue query:
``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sqs receive-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/third-queue | jq
```

Results:

``` json
{
  "Messages": [
    {
      "MessageId": "d13c456e-c748-4aba-a3e6-184ddf713b11",
      "ReceiptHandle": "MWEzMjVhYmUtMGEyMS00YmU4LWFhMTctNWRlYWFiOTcyNWJkIGFybjphd3M6c3FzOnVzLWVhc3QtMTowMDAwMDAwMDAwMDA6dGhpcmQtcXVldWUgZDEzYzQ1NmUtYzc0OC00YWJhLWEzZTYtMTg0ZGRmNzEzYjExIDE3NjAzMTE2NzAuNTM1MDUyMw==",
      "MD5OfBody": "67c98ede5ebd87fc77d50a1511ff3904",
      "Body": "{\"Type\": \"Notification\", \"MessageId\": \"5dc3350c-58ca-4b27-8730-914278bd7d88\", \"TopicArn\": \"arn:aws:sns:us-east-1:000000000000:first-topic\", \"Message\": \"{ 'event_id': '5b9b03fd-eaac-43df-969a-7a11295b5f9d', 'event_time': '2025-10-12 20:26:36Z', 'data': { 'some-id': 83411, 'name': 'Marco Minas', 'status': 'active' } }\", \"Timestamp\": \"2025-10-12T23:26:37.038Z\", \"UnsubscribeURL\": \"http://localhost.localstack.cloud:4566/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:000000000000:first-topic:650ce848-2f42-48e6-947c-1b79dacf4f50\", \"SignatureVersion\": \"1\", \"Signature\": \"gSgPu2SGSeXkvhnIsYcY7zD8gK4PFHSlxVEA9YY8cydY3gSLyZB6mrPniWEOouCNCxchl/+fsp23avjU3mdmeOGlEUVgMMu4bNLdloFVg2T2DOCuw9yzY0HuEu/NSFsSF1TTfqXsPD/IeGmbU81Kk7uuM6WJTmBGSMaPodo1jKk7e+afgWJcobnSvZwwAmXvoxHXvb7Z6NVoxCF1/YRdulY1fJ02YUKMWmUX8Y2PXd/9oyO08EAy/vivACOFTLWMWxS06nDyCXHFMI2FFDrvmVxsDpnuPehi+yoBj9Q4HZzMqF9OwwVH8k1l2NliKmjHgviq16PsBZI4RID0yjCEUA==\", \"SigningCertURL\": \"http://localhost.localstack.cloud:4566/_aws/sns/SimpleNotificationService-6c6f63616c737461636b69736e696365.pem\"}"
    }
  ]
}
``` 

And we have a inconsistency: at publish time, `MessageId` was `5dc3350c-58ca-4b27-8730-914278bd7d88` but retrieving messagem from queue `MessageId` is `d13c456e-c748-4aba-a3e6-184ddf713b11` - why?

It happens because `5dc3350c-58ca-4b27-8730-914278bd7d88` is the topic `MessageId` and this message was routed to queue and this create a queue `MessageId` retreived by queue message retrieval.

Now, try to publish same message but now add `eventType` attribute with `second-event` value on it.

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 sns publish --topic-arn arn:aws:sns:us-east-1:000000000000:first-topic --message "{ 'event_id': '$(uuidgen)', 'event_time': '$(date '+%Y-%m-%d %H:%M:%S')Z', 'data': { 'some-id': 83411, 'name': 'Marco Minas', 'status': 'active' } }" --message-attributes '{ "eventType": {"DataType": "String", "StringValue": "second-event" }  }' | jq
```

Is expected that `first-queue` retrieval results in nothing but `second-queue` and `third-queue` returns message with same `Body` containing sent message data.
