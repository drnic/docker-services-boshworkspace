docker-services-boshworkspace
=============================

The fastest way to deploy [Docker Services](https://github.com/cf-platform-eng/docker-boshrelease) in combination with [Cloud Foundry](http://www.cloudfoundry.org) onto [bosh-lite](https://github.com/cloudfoundry/bosh-lite).

### Preparation

To get started you will need a running bosh-lite. Get yours by following the instructions [here](https://github.com/cloudfoundry/bosh-lite#install-bosh-lite)

Next step is setting up this repository

```
git clone https://github.com/cloudfoundry-community/docker-services-boshworkspace.git
cd docker-services-boshworkspace
bundle install
```

### Deploy Docker Services

Initiate each new deployment with the following command:

```
bosh setup deployment
```

It will prompt you for which service to deploy (or ALL services).

Then, it will prompt for AWS/OpenStack specific questions. See those sections below.

For example with bosh-lite/warden you will see something like:

```
WARNING: loading local plugin: lib/bosh/cli/commands/setup_deployment.rb
Looking up 'cf-warden'...
1. ALL
2. ArangoDB 2.2
3. Consul 0.3.1
4. CouchDB 1.6
5. Elasticsearch 1.3
6. Etcd 0.4.6
7. Logstash 1.4
8. Memcached 1.4
9. MongoDB 2.6
10. MySQL 5.6
11. NATS
12. Neo4j 2.1
13. PostgreSQL 9.3
14. RabbitMQ 3.3
15. Redis 2.8
16. RethinkDB 1.14.0
Choose a service (or ALL): 12
bosh deployment deployments/my-neo4j21-services-warden.yml
WARNING: loading local plugin: lib/bosh/cli/commands/setup_deployment.rb
Deployment set to `.../.deployments/my-neo4j21-services-warden.yml'

bosh deploy
...
Are you sure you want to deploy? (type 'yes' to continue):
```

Type `yes` to continue with the deployment.


After BOSH finishes the deployment, the broker is not yet ready. The terminal will start polling for the broker. For a few minutes the VM will be downloading the 1 docker image per service.

Finally, you will be prompted to run a command like the one below. It will include the correct password:

```
cf create-service-broker docker containers PASSWORD http://cf-containers-broker.10.244.0.34.xip.io
```

Once the command above works you can now enable your services to some/all organizations:

```
cf service-access
cf enable-service-access <service_name>
```

### Deploy on AWS VPC

To deploy any or all the docker services to your AWS VPC, run:

```
bosh setup deployment
```

It will prompt you for the following and ultimately commence deployment of the VM:

- select your target Cloud Foundry (or will show the only CF deployment if there is only one)
- select a docker service to deploy into a single VM (or 'ALL' if your single VM wishes to support all docker services)
- select an AWS instance type (list include 64-bit, paravirtual, with some ephemeral disk for docker containers)
- specify the persistent disk size (where all services' data is stored)
- specify the subnet ID (e.g. `subnet-5d51d338`)
- specify the subnet range (e.g. `10.10.5.0/24`) OR
- specify the sub-range within a shared subnet (e.g. `10.10.5.16/30`)
- confirm to commence deployment of the new BOSH deployment manifest

The output will look similar to below:

```
$ bosh setup deployment
WARNING: loading local plugin: lib/bosh/cli/commands/setup_deployment.rb
Looking up 'cf-aws-tiny'...

1. ALL
2. Memcached 1.4
3. MongoDB 2.6
4. CouchDB 1.6
5. NATS
6. Redis 2.8
7. Elasticsearch 1.3
8. Neo4j 2.1
9. Logstash 1.4
10. Etcd 0.4.6
11. Consul 0.3.1
12. PostgreSQL 9.3
13. MySQL 5.6
14. RabbitMQ 3.3
15. RethinkDB 1.14.0
16. ArangoDB 2.2
Choose a service (or ALL): 2

Security groups: cf-0-vpc-fa2f849f

1. m1.large (850 disk, 7680 ram, 4 cores)
2. m1.xlarge (1690 disk, 15360 ram, 8 cores)
3. c1.xlarge (1690 disk, 7168 ram, 20 cores)
4. c3.large (32 disk, 3750 ram, 7 cores)
5. c3.xlarge (80 disk, 7168 ram, 14 cores)
...
Instance type: 1

Persistent disk volume size (Gb): 200

Subnet ID: subnet-5d51d338
No other deployments using same subnet
Subnet CIDR range: 10.10.5.0/24
```

It will then automatically target the generated deployment manifest:

```
bosh deployment deployments/cf-containers-broker-memcached14.yml
Deployment set to `.../.deployments/cf-containers-broker-memcached14.yml'
```

And then attempt to deploy the new deployment manifest:

```
bosh deploy

WARNING: loading local plugin: lib/bosh/cli/commands/setup_deployment.rb
Generating deployment manifest
...
Deploying
---------
Deployment name: `cf-containers-broker-memcached14.yml'
Director name: `bosh-vpc-fa2f849f'
Are you sure you want to deploy? (type 'yes' to continue):
```

Type `yes` to continue with the deployment.

After BOSH finishes the deployment, the broker is not yet ready. The terminal will start polling for the broker. For a few minutes the VM will be downloading the 1 docker image per service.

Finally, you will be prompted to run a command like the one below. It will include the correct password:

```
cf create-service-broker docker containers PASSWORD http://cf-containers-broker.10.244.0.34.xip.io
```

Once the command above works you can now enable your services to some/all organizations:

```
cf service-access
cf enable-service-access <service_name>
```
