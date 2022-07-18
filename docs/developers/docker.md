---
id: docker
title: Docker Images
sidebar_label: Docker Images
---

Pupilfirst uses Docker to build and release [official images to our Docker Hub account](https://hub.docker.com/r/pupilfirst/pupilfirst/tags). These images are built automatically using Github CI on the project repo.

However, there may be situations in which you do not wish to use these official images. For example, if you've made changes to your fork of Pupilfirst, then you'll want to deploy Docker images that incorporate those changes.

You can build your own Docker image locally:

```bash
# From the root of the repo...
docker build -t pupilfirst .
```

This command will instruct Docker to locally build an image using instructions in the `Dockerfile`, and to tag the resulting image as `pupilfirst`.

Once an image has been built, you can run it locally, and even inspect its contents:

```bash
# Start a container using the `pupilfirst` image, and run bash.
docker run -it --entrypoint bash pupilfirst
```

Once you've confirmed that your image is functioning properly, you can add new tags to the local image and _push_ it to your target container registry, such as [Docker Hub](https://hub.docker.com), [Heroku Container Registry](https://devcenter.heroku.com/articles/container-registry-and-runtime), or [DigitalOcean Container Registry](https://docs.digitalocean.com/products/container-registry/).

First, add new tags to your local image:

```bash
# Let's use Heroku as an example.
docker tag pupilfirst registry.heroku.com/APP_NAME/web
docker tag pupilfirst registry.heroku.com/APP_NAME/worker
```

Once the tags are in place, you can use the `push` command:

```bash
# Heroku Container Registry
docker push registry.heroku.com/APP_NAME/web
docker push registry.heroku.com/APP_NAME/worker

# DigitalOcean Container Registry
docker push registry.digitalocean.com/REGISTRY/pupilfirst:latest

# Docker Hub
docker push USERNAME/pupilfirst:latest
```

You will need to perform additional steps beforehand to be allowed to push to these container registries; please browse their documentation for more information.
