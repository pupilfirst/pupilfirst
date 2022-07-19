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

In addition to the environment variables listed there, make sure that you have the following additional variables:

```bash
# Configure the bin/start script to migrate the database when it runs, and to set up the
# cron to run required scheduled jobs.
WORKER_MIGRATE=true
WORKER_SETUP_CRON=true

# Component-level environment variables. This will control whether it's the web process,
# or the worker process that executes when the bin/start script runs.
PROCESS_TYPE=web OR worker
```
