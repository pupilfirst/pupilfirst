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

On DigitalOcean's App Platform, you'll need three components minimum - a web process (to server web requests), a worker process (to run background jobs), and a scheduler process (to run scheduled jobs).

You can run these different processes by using the following environment variables:

```bash
# Component-level environment variables. This will control whether it's the web process,
# the worker process, or the scheduler process that executes when the bin/start script runs.
PROCESS_TYPE=web|worker|scheduler

# Configure the worker process to run database migrations before it loads.
WORKER_MIGRATE=true
```
