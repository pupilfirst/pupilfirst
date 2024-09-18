---
id: digitalocean
title: Deploying to DigitalOcean
sidebar_label: DigitalOcean
---

## Before deploying

Start by making sure that you've gone through [our notes of some things to consider before deploying](before_deploying).

**Warning:** Documentation for deployment to DigitalOcean is incomplete; it lacks platform-specific guidelines.

However, most of the steps you'll need to follow are identical to [what you'll need to do on Heroku](./heroku). This is because we use Docker images for deployment there as well.

Deploying to DigitalOcean is more convenient than Heroku because you can pull Docker images straight from Docker Hub without having to use an intermediary container registry.

## Deploy using images from Docker Hub

[Docker images for the LMS](./docker) can be found on [our official Docker Hub account](https://hub.docker.com/r/pupilfirst/pupilfirst).

These images are ideal for quickly and easily deploying the LMS to
[Digital Ocean's App Platform](https://www.digitalocean.com/products/app-platform).

## Environment variables

There are several environment variables you'll need to set up to get the application fully functional. These variables are [documented separately](./configuration).

## Components

On DigitalOcean's App Platform, you'll need three components minimum:

1. **A web process**: To serve incoming web requests.
2. **A worker process**: To run background jobs such as sending emails, generate exports, process submissions, and many more deferred tasks.
3. **A scheduler process**: To run scheduled jobs - database cleanup, mailing daily digests and to notify and delete inactive users. The [timing for these tasks is configurable](./configuration#scheduled-jobs).

You can run these different processes by using the following environment variables:

```bash
# Set up this component-level environment variable to control whether it'll run as a web
# process, a worker process, or as a scheduler process that executes when the bin/start
# script is executed in the Docker image. This script handles process initialization
# based on the PROCESS_TYPE environment variable
PROCESS_TYPE=[web / worker / scheduler]

# Set the following environment variable for one worker component to allow it to run
# database migrations before it loads.
WORKER_MIGRATE=true

# Example for a web process:
PROCESS_TYPE=web

# Example for a worker process with migrations:
PROCESS_TYPE=worker
WORKER_MIGRATE=true
```
