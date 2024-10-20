# Adding KMS feature

On [docker-compose file](../docker-compose.yml), change `SERVICES: 'sqs,s3,dynamodb,kms'` to `SERVICES: 'sqs,s3,dynamodb,kms,route53'` adding AWS KMS service.

Also add this two ports:
``` bash
    ports:
      - "127.0.0.1:53:53"                # Expose DNS server to host
      - "127.0.0.1:53:53/udp"            # Expose DNS server to host
```

## Useful commands

### Create a hosted zone

``` bash
zone_id=$(aws --endpoint-url=http://localhost:4566 route53 create-hosted-zone --name mmcwebsolutions.io --caller-reference r1 | jq -r '.HostedZone.Id') && echo $zone_id
```

Expected result:
``` text
/hostedzone/LYR7YG78QNK44E6
```

### Change resource record sets

``` bash
aws --endpoint-url=http://localhost:4566 route53 change-resource-record-sets --hosted-zone-id $zone_id --change-batch 'Changes=[{Action=CREATE,ResourceRecordSet={Name=marco.mmcwebsolutions.io,Type=A,ResourceRecords=[{Value=1.2.3.4}]}}]' | jq
```

Expected result:
``` json
{
    "ChangeInfo": {
        "Id": "/change/C2682N5HXP0BZ4",
        "Status": "INSYNC",
        "SubmittedAt": "2010-09-10T01:36:41.958000Z"
    }
}
```

### Query DNS record

``` bash
 dig @localhost marco.mmcwebsolutions.io
```

Expected result:
``` text
; <<>> DiG 9.18.28-0ubuntu0.20.04.1-Ubuntu <<>> @localhost marco.mmcwebsolutions.io
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 49074
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;marco.mmcwebsolutions.io.      IN      A

;; Query time: 74 msec
;; SERVER: 127.0.0.1#53(localhost) (UDP)
;; WHEN: Sun Oct 20 17:37:52 -03 2024
;; MSG SIZE  rcvd: 42
```
