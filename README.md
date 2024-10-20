# A personal learnig experience with Localstack

## Quickstart

Reference:
- [x] [Getting started - quickstart](https://docs.localstack.cloud/getting-started/quickstart/)
- [x] [Localstack 101](https://docs.localstack.cloud/academy/localstack-101/)
- [x] [Gitlab CI test containers](https://docs.localstack.cloud/tutorials/gitlab_ci_testcontainers/)


## Useful commands

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
