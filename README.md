# Multi Wordpress Sites

Sets up multiple wordpress sites on same machine using `docker-compose`.

## Motivation

To save money! The purpose of hosting multiple wordpress site on 1 server is to save the server cost. when I just start out sites, I am reluctant to spend money on them without a clear ROI.

This setup allows me to serve the sites at the cost of 1 server.

## Considerations

It might be better to serve these sites using kubernetes which orchestrates the deployment and ensure there is no downtime. However, it is costly and not for my use case of such a small scale.

Using kubernetes on just 1 server may still work and allow for scaling with ease in the future, but the master node itself will require high RAM, which translates to high unnecessary costs again, for my use case. Hence, back to `docker-compose`.

The RAM usage of docker on my local machine when running 3 wordpress sites was less than 1GB, using `docker stats` to benchmark. Hence, it does not require a large amount of ram. This requires testing as stated in [TODO](#TODO).

This setup will not be able to handle high traffic load. My mitigation involves using a CDN to reduce the actual traffic on the server. I will be using `AWS CloudFront` to cache the resources and tank the load, relieving the small server from load.

[`AWS CloudFront` allows for POST requests from its edge locations too, so a typical website with write requests can still function properly. However, the load problem will occur if too much POST requests occur, but that is unlikely. If website is targeted by bots and that unlikely scenario occurs, there should be other methods to mitigate this apart from scaling the servers. Captcha on the frontend is one of these methods for example.

## Architecture

For each wordpress service, the wordpress fpm docker image is used for the wordpress engine. The content is mapped to a local directory. Each wordpress service will have its own database, whose volume is mapped to local directories respective to each service as well.

There will be a single `nginx` service to act as the gatekeeper for request traffic entering the server and directing the traffic to the correct wordpress service on the server.

To add more sites to the setup read [here](#More Than 2 Sites).

## Usage

Pull this repository in a server in the cloud with docker installed.

### Development

Port 9000 is used by `fastcgi_pass`. Do not set port to 9000 for visualizer

Run the command to start the wordpress sites in the root directory of the repository.

```
docker-compose up
```

### Deployment

To be deployed on an EC2.

#### Variables

Some variables need to be changed.

`wp1`, `wp2`, `db1` and `db2` are the sample databases for this project's setup. Change accordingly to the name of your projects you desired. Make sure add the folders resultant from these name changes in `.dockerignore` file so that it is not pushed to Docker daemon as part of the "build context" to save time when building any images.

In the `docker-compose.yml` file, look for `## for development only` and `## for production` and uncomment commented codes and vice versa accordingly.

In the `nginx.conf` file, which will be used once the uncomment action is done in the `docker-compose.yml` file, switch the `server_name` to the domain/subdomain/ipaddress that will be used for the respective wordpress sites.

#### Commands

To deploy, first setup the docker swarm, then deploy the stack by running
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

#### Volumes

With reference to the `docker-compose.yml` file, the `volumes` of each image is stored in the a virtual hard disk of the server. This is understandably not ideal as compared to using managed databases like `AWS RDS`. However, since we are just starting out, this is mitigatable, although we can scale with this setup and not use managed databases.

Mounted volumes should be external harddisks separated from the boot disk that comes together with an AWS EC2 instances. This decoupling will allow better management of the data that need to be persisted and the ec2 instances that should be easily replicated.

Should there be a need to scale with the addition of more servers, which is [highly unlikely](#Considerations) and in which case the site should be generating enough monetary revenue for you to invest in a better system than this project, consider the usage of `AWS EFS`. It is a virtual storage that can be mounted to multiple EC2 instances and can be set as the mounted volume of the host in the `volumes` of each images in the `docker-compose.yml` file.

Data backups should be done on the EBS or EFS snapshot. `AWS Backup service` can be considered.

#### Ports

Ports that are set cannot be changed once the site is installed. The site will refer to the initial port that it was setup with when it looks for its assets.

Use 8xxx port range for all wordpress apps, except 8080 which is used for `docker-visualizer`.
Port 9000 is used by `fastcgi_pass`.

### More Than 2 Sites

To have more than 2 sites, create new `db` and `wp` images in the `docker-compose.yml` file, and add on to the `depends_on`, `volumes`, `ports` (only development needs to add a new listener) keys in the `web` service.

In the `nginx` file, add listener to the new `wp` for `fastcgi_pass` params. Add to the `listen` directive on the ports you used for the new images.

## TODO

1. Find out why docker stack deploy does not creat volumes.
2. Better way to manage changing variables in `docker-compose.yml` file for different environments

## Current Progress
