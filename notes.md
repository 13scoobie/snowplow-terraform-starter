

### General
- Use the aws keys in the environment instead of hard code in the variables.tf
- Use docker to run Terraform. This is recommended as Terraform does not guarantee backward compatibility.  Simple configuration is in `docker-compose.yml`
```
docker-compose run run --rm tf init
docker-compose run run --rm tf validate
docker-compose run run --rm tf plan
docker-compose run run --rm tf apply
```

### Load balancer
- The ELB works - changed it to listen on port 8000

### Collector
Works
- Updated to the most recent configuration file
- Updated links to download executable
- Update the command to start the collector


### Enrich
Same updates as the Collector

There is an error in AWS with respect to the Kinesis shards. Here is the solution.
- The proper Kinesis policies are mentioned [here](https://stackoverflow.com/questions/48322207/amazon-kinesis-caught-exception-while-syncing-kinesis-shards-and-leases).
- Do not configure DynamoDB tables in Terraform. They are created automatically when the streams start.  *Note*: These need to be deleted manually.  

### S3
Same updates as Enrich

The canned acl configuration does not allow the ec2 instance to write to the bucket. I set it to `acl = "public-read-write"` for now. But this is not recommended according to AWS docs. Will look for another way.
