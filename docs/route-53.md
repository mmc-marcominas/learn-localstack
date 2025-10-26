# AWS Route 53 Service Guide

This guide demonstrates how to use Amazon Route 53 with LocalStack for DNS management and domain name resolution.

## 🎯 Overview

Amazon Route 53 is a highly available and scalable cloud Domain Name System (DNS) web service. This guide covers essential Route 53 operations including hosted zone management, DNS record creation, and domain resolution.

## 🚀 Getting Started

### Prerequisites

- LocalStack running with Route 53 service enabled
- AWS CLI configured for LocalStack (`awslocal` command)
- `jq` for JSON formatting (optional)
- `dig` command for DNS queries (optional)

### Service Configuration

Ensure Route 53 is enabled in your `docker-compose.yml`:

```yaml
environment:
  SERVICES: 'sqs,s3,sns,dynamodb,kms,route53'

ports:
  - "127.0.0.1:53:53"                # Expose DNS server to host
  - "127.0.0.1:53:53/udp"            # Expose DNS server to host
```

## 📋 Core Operations

### 1. Hosted Zone Management

#### Create a Hosted Zone

Create a new hosted zone for your domain:

```bash
# Create hosted zone
zone_id=$(aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 create-hosted-zone \
    --name example.com \
    --caller-reference "r1-$(date +%s)" \
    | jq -r '.HostedZone.Id')

echo "Created hosted zone: $zone_id"
```

**Expected Response:**
```bash
Created hosted zone: /hostedzone/LYR7YG78QNK44E6
```

#### List Hosted Zones

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 list-hosted-zones | jq
```

**Expected Response:**
```json
{
  "HostedZones": [
    {
      "Id": "/hostedzone/LYR7YG78QNK44E6",
      "Name": "example.com.",
      "CallerReference": "r1-1729453051",
      "Config": {
        "PrivateZone": false
      },
      "ResourceRecordSetCount": 2
    }
  ]
}
```

#### Get Hosted Zone Details

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 get-hosted-zone --id "$zone_id" | jq
```

### 2. DNS Record Management

#### Create A Record

Add an A record pointing to an IP address:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 change-resource-record-sets \
    --hosted-zone-id "$zone_id" \
    --change-batch '{
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "www.example.com",
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "192.168.1.100"
                        }
                    ]
                }
            }
        ]
    }'
```

**Expected Response:**
```json
{
    "ChangeInfo": {
        "Id": "/change/C2682N5HXP0BZ4",
        "Status": "INSYNC",
        "SubmittedAt": "2024-10-20T18:47:02.000Z"
    }
}
```

#### Create CNAME Record

Add a CNAME record for subdomain aliasing:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 change-resource-record-sets \
    --hosted-zone-id "$zone_id" \
    --change-batch '{
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "api.example.com",
                    "Type": "CNAME",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "api-server.example.com"
                        }
                    ]
                }
            }
        ]
    }'
```

#### Create MX Record

Add MX records for email routing:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 change-resource-record-sets \
    --hosted-zone-id "$zone_id" \
    --change-batch '{
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "example.com",
                    "Type": "MX",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "10 mail1.example.com"
                        },
                        {
                            "Value": "20 mail2.example.com"
                        }
                    ]
                }
            }
        ]
    }'
```

#### Create TXT Record

Add TXT records for domain verification or SPF:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 change-resource-record-sets \
    --hosted-zone-id "$zone_id" \
    --change-batch '{
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "example.com",
                    "Type": "TXT",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "\"v=spf1 include:_spf.google.com ~all\""
                        }
                    ]
                }
            }
        ]
    }'
```

### 3. DNS Resolution Testing

#### Query DNS Records

Test DNS resolution using the `dig` command:

```bash
# Query A record
dig @localhost www.example.com A

# Query CNAME record
dig @localhost api.example.com CNAME

# Query MX record
dig @localhost example.com MX

# Query TXT record
dig @localhost example.com TXT
```

**Expected Response:**
```bash
; <<>> DiG 9.18.28-0ubuntu0.20.04.1-Ubuntu <<>> @localhost www.example.com A
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 49074
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;www.example.com.      IN      A

;; ANSWER SECTION:
www.example.com.   300 IN      A       192.168.1.100

;; Query time: 74 msec
;; SERVER: 127.0.0.1#53(localhost) (UDP)
;; WHEN: Sun Oct 20 17:37:52 -03 2024
;; MSG SIZE  rcvd: 42
```

#### List Resource Record Sets

View all DNS records in a hosted zone:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 list-resource-record-sets --hosted-zone-id "$zone_id" | jq
```

**Expected Response:**
```json
{
  "ResourceRecordSets": [
    {
      "Name": "example.com.",
      "Type": "NS",
      "TTL": 172800,
      "ResourceRecords": [
        {
          "Value": "ns-1234.awsdns-12.org"
        }
      ]
    },
    {
      "Name": "example.com.",
      "Type": "SOA",
      "TTL": 900,
      "ResourceRecords": [
        {
          "Value": "ns-1234.awsdns-12.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
        }
      ]
    },
    {
      "Name": "www.example.com.",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [
        {
          "Value": "192.168.1.100"
        }
      ]
    }
  ]
}
```

### 4. Advanced Operations

#### Update DNS Records

Modify existing DNS records:

```bash
# Update A record
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 change-resource-record-sets \
    --hosted-zone-id "$zone_id" \
    --change-batch '{
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "www.example.com",
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "192.168.1.200"
                        }
                    ]
                }
            }
        ]
    }'
```

#### Delete DNS Records

Remove DNS records:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 change-resource-record-sets \
    --hosted-zone-id "$zone_id" \
    --change-batch '{
        "Changes": [
            {
                "Action": "DELETE",
                "ResourceRecordSet": {
                    "Name": "api.example.com",
                    "Type": "CNAME",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "api-server.example.com"
                        }
                    ]
                }
            }
        ]
    }'
```

#### Health Checks

Create health checks for monitoring:

```bash
health_check_id=$(aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 create-health-check \
    --caller-reference "$(date +%s)" \
    --health-check-config '{
        "Type": "HTTP",
        "ResourcePath": "/health",
        "FullyQualifiedDomainName": "www.example.com",
        "Port": 80,
        "RequestInterval": 30,
        "FailureThreshold": 3
    }' \
    | jq -r '.HealthCheck.Id')

echo "Created health check: $health_check_id"
```

To validate it:

``` bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 get-health-check \
    --health-check-id "$health_check_id"
```

## 🔧 Practical Examples

### Complete Domain Setup

Set up a complete domain with multiple record types:

```bash
#!/bin/bash

# Create hosted zone
zone_id=$(aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 create-hosted-zone \
    --name myapp.local \
    --caller-reference "setup-$(date +%s)" \
    | jq -r '.HostedZone.Id')

echo "Created hosted zone: $zone_id"

# Add A record for main domain
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 change-resource-record-sets \
    --hosted-zone-id "$zone_id" \
    --change-batch '{
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "myapp.local",
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": [{"Value": "10.0.1.100"}]
                }
            }
        ]
    }'

# Add www subdomain
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 change-resource-record-sets \
    --hosted-zone-id "$zone_id" \
    --change-batch '{
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "www.myapp.local",
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": [{"Value": "10.0.1.100"}]
                }
            }
        ]
    }'

# Add API subdomain
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 change-resource-record-sets \
    --hosted-zone-id "$zone_id" \
    --change-batch '{
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "api.myapp.local",
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": [{"Value": "10.0.1.200"}]
                }
            }
        ]
    }'

echo "Domain setup complete!"
```

### Load Balancing with Multiple A Records

Configure load balancing using multiple A records:

```bash
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 change-resource-record-sets \
    --hosted-zone-id "$zone_id" \
    --change-batch '{
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "load-balanced.myapp.local",
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": [
                        {"Value": "10.0.1.100"},
                        {"Value": "10.0.1.101"},
                        {"Value": "10.0.1.102"}
                    ]
                }
            }
        ]
    }'
```

## ⚠️ Important Notes

### DNS Propagation

- Changes to DNS records may take time to propagate
- TTL (Time To Live) values affect how quickly changes are reflected
- LocalStack provides immediate updates for testing purposes

### Record Types

Common DNS record types supported:

- **A**: IPv4 address
- **AAAA**: IPv6 address
- **CNAME**: Canonical name (alias)
- **MX**: Mail exchange
- **TXT**: Text record
- **NS**: Name server
- **SOA**: Start of authority

### TTL Values

- **300 seconds (5 minutes)**: Good for testing and development
- **3600 seconds (1 hour)**: Common for production
- **86400 seconds (24 hours)**: For stable records

### Health Checks

Health checks monitor the availability of your resources:

- **HTTP/HTTPS**: Check web server availability
- **TCP**: Check port connectivity
- **CALCULATED**: Combine multiple health checks

## 🔍 Troubleshooting

### Common Issues

#### DNS Resolution Not Working
```bash
# Check if Route 53 service is running
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 list-hosted-zones | jq

# Verify DNS server is accessible
dig @localhost example.com NS
```

#### Record Not Found
```bash
# List all records in hosted zone
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 list-resource-record-sets --hosted-zone-id "$zone_id" | jq

# Check specific record
dig @localhost www.example.com A
```

#### Permission Issues
```bash
# Verify hosted zone exists
aws --endpoint-url=http://localhost:4566 --region us-east-1 route53 get-hosted-zone --id "$zone_id" | jq
```

## 📚 Additional Resources

- [AWS Route 53 Documentation](https://docs.aws.amazon.com/route53/)
- [LocalStack Route 53 Guide](https://docs.localstack.cloud/user-guide/aws/route53/)
- [DNS Best Practices](https://docs.aws.amazon.com/route53/latest/developerguide/dns-best-practices.html)
- [Health Checks](https://docs.aws.amazon.com/route53/latest/developerguide/health-checks.html)
