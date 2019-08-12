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

## Usage

Pull this repository in a server in the cloud with docker installed.

### Development

Run the command to start the wordpress sites in the root directory of the repository.

```
docker-compose up
```

#### Ports

Ports that are set cannot be changed once the site is installed. The site will refer to the initial port that it was setup with when it looks for its assets.

## TODO

1. Test RAM usage on a small EC2 usage.