# A personal learnig experience with Localstack

## Quickstart

Reference:

- [x] [Getting started - quickstart](https://docs.localstack.cloud/getting-started/quickstart/)
- [x] [Localstack 101](https://docs.localstack.cloud/academy/localstack-101/)
- [x] [Gitlab CI test containers](https://docs.localstack.cloud/tutorials/gitlab_ci_testcontainers/)


## Useful commands

### Load instance

``` bash
docker compose up
```

Expected result sample:
``` bash
[+] Running 1/1
 ✔ Container localstack-main  Created                                                                          0.3s
Attaching to localstack-main
localstack-main  | LocalStack supervisor: starting
localstack-main  | LocalStack supervisor: localstack process (PID 15) starting
localstack-main  | 2024-10-20T16:02:10.429 DEBUG --- [  MainThread] l.utils.docker_utils       : Using SdkDockerClient. LEGACY_DOCKER_CLIENT: False, SDK installed: True
localstack-main  | 2024-10-20T16:02:11.147  WARN --- [  MainThread] l.services.internal        : Enabling diagnose endpoint, please be aware that this can expose sensitive information via your network.
localstack-main  | 2024-10-20T16:02:11.181 DEBUG --- [  MainThread] plux.runtime.manager       : instantiating plugin PluginSpec(localstack.runtime.components.aws = <class 'localstack.aws.components.AwsComponents'>)
localstack-main  | 2024-10-20T16:02:11.181 DEBUG --- [  MainThread] plux.runtime.manager       : loading plugin localstack.runtime.components:aws
localstack-main  |
localstack-main  | LocalStack version: 3.7.3.dev40
localstack-main  | LocalStack build date: 2024-09-21
localstack-main  | LocalStack build git hash: 007dde9f2
...
```

See [detailed initialization explanation here](./docs/init.md).

### Local stack info

`curl http://localhost:4566/_localstack/info | jq`

Expected result sample:
``` json
{
  "version": "3.7.3.dev40:007dde9f2",
  "edition": "community",
  "is_license_activated": false,
  "session_id": "dfcd37d1-2c2f-484f-bf65-4e00a0434aac",
  "machine_id": "dkr_8b45de376e9f",
  "system": "linux",
  "is_docker": true,
  "server_time_utc": "2024-09-22T19:12:26",
  "uptime": 3464
}
```

If jq not installed: `sudo apt  install jq`

## Trying AWS S3 service on Localstack

Enable S3 on Localstack is very easy, [this AWS S3 documentation](./docs/s3.md) show how to do this.

Try execute all commands and you will:

 - [x] create a bucket
 - [x] add a object on created bucket
 - [x] lis buckets and it's contents
 - [x] create a signed url and access via curl

## Trying AWS DynamoDB service on Localstack

Enable DynamoDB on Localstack is very simple too, [this AWS DynamoDB documentation](./docs/dynamo-db.md) show how to do this.

Try execute all commands and you will:
 - [x] create a table
 - [x] add items on created bucket
 - [x] list tables and it's contents
 - [x] query/filter items on table

## Trying AWS KMS service on Localstack

Enable KMS on Localstack is very simple too, [this AWS KMS documentation](./docs/kms-md) show how to do this.

Try execute all commands and you will:

 - [x] create KMS key
 - [x] encrypt data with created key
 - [x] decrypt data

## Trying AWS Route 53 service on Localstack

To enable Route 53 on Localstack, read [this AWS Route 53 documentation](./docs/route-53.md).

Try execute all commands and you will:
 - [x] create a hosted zone
 - [x] Change resource record sets
 - [x] query DNS record

## Using SQS

Read [this SQS documentation](./docs/sqs.md) and you will:

 - [x] list queues
 - [x] send message to queue
 - [x] receive sent message
 - [x] delete sent message
 - [x] validate DLQ queue configuration
 - [x] validate DLQ queue configuration
