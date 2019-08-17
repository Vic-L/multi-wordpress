## Multi Wordpress Sites

Sets up multiple wordpress sites on same machine.

## Motivation

The purpose of hosting multiple wordpress site on 1 server is to save the server cost. When I just start out new sites, I am reluctant to spend money on them without a clear ROI.

This setup allows me to serve the sites at the cost of 1 server. It can be used on many account which I may have for different personas.

### Considerations

1. It might be better to serve these sites using kubernetes (this project uses containerization technologies) to orchestrates the deployment and ensure there is no downtime. However, it is costly and not for my use case of such a small scale.

2. Using kubernetes on just 1 server may still work and allow for scaling with ease in the future. It also ensure blue green deployment and maximum uptime. However, the master node itself will require high RAM, which translates to high costs again. It does not fit my use case. TODO: Currently testing with `docker stack`, if it takes up a lot of RAM too, need to find alternatives.

3. The RAM usage of docker on my local machine when running 3 wordpress sites was less than 1GB, using `docker stats` to benchmark. Hence, it does not require a large amount of ram, cost can be brought down.

4. This setup will not be able to handle high traffic load. My mitigation involves using a CDN to reduce the actual traffic on the server. I will be using `AWS CloudFront` to cache the resources and tank the load, relieving the small server from load.

5. [`AWS CloudFront` allows for POST requests from its edge locations too, so a typical website with write requests can still function properly. However, the load problem will occur if too much POST requests occur, but that is unlikely. If website is targeted by bots and that unlikely scenario occurs, there should be other methods to mitigate this apart from scaling the servers. Captcha on the frontend is one of these methods for example.

6. Should there be that many genuine POST requests, we should be in a position to be able to afford to spend more money on better and proper infrastructure like kubernetes. This setup can be easily portable. Read more about the [Architecture](#Architecture) in the [Features](#Features) section.

## Build status

-

## Code style

[Naming convention on Terraform](https://www.terraform.io/docs/extend/best-practices/naming.html).
 
## Screenshots

-

## Tech/framework used

* Docker Compose
* Docker Stack
* Dockerfile
* Terraform
* Makefile

## Features

Easily setup multiple wordpress sites on the same server.

Data can be ported should there be a need to scale and decouple.

For each wordpress service, the wordpress fpm docker image is used for the wordpress engine. The content is mapped to a local directory. Each wordpress service will have its own database, whose volume is mapped to local directories respective to each service as well.

NOTE: the directories will be created automatically on development with `docker-compose up -d`. However, `docker stack deploy` will not do so. It will require the folders to exist.

There will be a single `nginx` service to act as the gatekeeper for request traffic entering the server and directing the traffic to the correct wordpress service on the server.

Docker visualizer is meant to monitor the containers. However, precaution should be taken to deploy in production.

### Add More Sites

Port 9000 is used by `fastcgi_pass`. Do not set port to 9000 for visualizer.

## Installation

* Install Docker
* Install Make

## Usage

### Development

Run the command to start the wordpress sites in the **root directory**:

```
docker-compose up -d
```
This will setup 2 wp sites, `wp1` and `wp2`, and their respective databases, `db1` and `db2`, mapped to newly created directories. 

TODO how to add more sites? This repository is meant for reference if you want to setup similar multiple WP sites on the same server. It will require changing variables in the files, which require understanding of how everything is pieced together.

To stop, run:
```
docker-compose down
```

The databases and wordpress content will persist when you start the server subsequently.

### Production

#### SSH Key

Generate an ssh key and name it `multi_wordpress`. the output files are `multi_wordpress` and `multi_wordpress.pub`. Save them to the root directory of this project. This keys will be used to generate the aws key pair and connect to the ec2 instance during provision.

NOTE: store these keys securely, but make them available within the root directory during deployment operations involving Terraform as the config file will be referencing them.

#### Variables

Before deployment to production, some variables need to be changed.

`wp1`, `wp2`, `db1` and `db2` are the sample databases for this project's setup. Change accordingly to the name of your projects you desired. Make sure add the folders resultant from these name changes in `.dockerignore` file so that it is not pushed to Docker daemon as part of the "build context" to save time when building any images. These folders are meant for development only. When push to server, the folders need to be created manually (they need to exist first as a requirement for a `named volume` to be binded to local directory).

In the `docker-compose.yml` file, look for `## for development only` and `## for production` and uncomment commented codes and vice versa accordingly.

TODO write init script to auto replace on project startup and test script? ### More Than 2 Sites. To have more than 2 sites, create new `db` and `wp` images in the `docker-compose.yml` file, and add on to the `depends_on`, `volumes`, `ports` (only development needs to add a new listener) keys in the `web` service.

In the `nginx` file, add listener to the new `wp` for `fastcgi_pass` params. Add to the `listen` directive on the ports you used for the new images.

In the `nginx.conf` file, which will be used once the uncomment action is done in the `docker-compose.yml` file, switch the `server_name` to the domain/subdomain/ipaddress that will be used for the respective wordpress sites.

TODO after terraform config, figure out how to run the app in production.
To run in production, first setup the docker swarm, then deploy the stack by running
```
# NOTE: `docker stack deploy` command does not build the volumes (TODO why?)
# Run `docker-compose up` first before `docker-compose down` and then the `docker stack deploy` command.
docker swarm init
docker stack deploy -c docker-compose.yml multi_wp # or any custom name for the stack
```

It might take some time for the services to be implemented completely. Run the command below to verify that the services that are running.
```
docker service ls
```

To stop, run
```
# for single-node manager node
docker swarm leave --force

# for worker node, if any
docker swarm leave
```

## Tests
Describe and show how to run the tests with code examples.

## How to use?
If people like your project they’ll want to learn how they can use it. To do so include step by step guide to use your project.

## Contribute

Let people know how they can contribute into your project. A [contributing guideline](https://github.com/zulip/zulip-electron/blob/master/CONTRIBUTING.md) will be a big plus.

## Credits



## License
A short snippet describing the license (MIT, Apache etc)

MIT © [Yourname]()




#### Commands



#### Volumes

With reference to the `docker-compose.yml` file, the `volumes` of each image is stored in the a virtual hard disk of the server. This is understandably not ideal as compared to using managed databases like `AWS RDS`. However, since we are just starting out, this is mitigatable, although we can scale with this setup and not use managed databases.

Mounted volumes should be external harddisks separated from the boot disk that comes together with an AWS EC2 instances. This decoupling will allow better management of the data that need to be persisted and the ec2 instances that should be easily replicated.

Should there be a need to scale with the addition of more servers, which is [highly unlikely](#Considerations) and in which case the site should be generating enough monetary revenue for you to invest in a better system than this project, consider the usage of `AWS EFS`. It is a virtual storage that can be mounted to multiple EC2 instances and can be set as the mounted volume of the host in the `volumes` of each images in the `docker-compose.yml` file.

Data backups should be done on the EBS or EFS snapshot. `AWS Backup service` can be considered.

#### Ports

Ports that are set cannot be changed once the site is installed. The site will refer to the initial port that it was setup with when it looks for its assets.

Use 8xxx port range for all wordpress apps, except 8080 which is used for `docker-visualizer`.
Port 9000 is used by `fastcgi_pass`.


1. Better way to manage changing variables in `docker-compose.yml` file for different environments


## NOTES for content writing
### Terraform

These are notes in point form. Require organising and update before merging into master.

* `key_name` of `aws_instance` need to be existing
* Named profile setup for is required for deploying terraform
* tags `Name` are `multi_wordpress` by default
* makefile using -target flag to destroy all resources except the ebs_volume that needs to persist, refer [this issue](https://github.com/terraform-providers/terraform-provider-aws/)issues/2416)
* `depends_on` module not working for `module`. So there may be race condition when creating the s3 secrets bucket and its logging bucket if they do not already exist.
* s3 secrets folder to store all ssh keys (https://stackoverflow.com/a/52868251/2667545) to git pull

## Current Progress
mount ebs and only format it if empty
create folders

## TODO