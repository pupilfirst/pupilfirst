---
id: heroku
title: Deploying to Heroku
sidebar_label: Heroku
---

## Before deploying

Start by making sure that you've gone through [our notes of some things to consider before deploying](before_deploying).

## Steps on Heroku

Begin by [signing up on Heroku](https://signup.heroku.com), and familiarizing yourself with [how containerized apps run on Heroku](https://devcenter.heroku.com/articles/container-registry-and-runtime).

### Set up the Heroku app

1. Create a new Heroku app, to which we'll deploy Pupilfirst.
2. Attach a PostgreSQL database as an add-on to your Heroku application. You can do this from the _Resources_ tab on Heroku.
3. [Configure your new Heroku app](https://devcenter.heroku.com/articles/config-vars) using environment variables.

   Make sure that you set up [all required environment variables](./configuration) - we've documented these separately since they're common to different deployment targets.

   Additionally, make sure that set the following variable is also set:

   ```
   TINI_SUBREAPER=true
   ```

## Deployment using Docker

The Heroku Container Registry allows us to deploy [our Docker images](./docker) to Heroku. To access the Heroku Container Registry, we first need to log into it:

```bash
heroku container:login
```

Once we are logged in we can push our image to the registry and deploy our app. Pupilfirst maintains [official images on Docker Hub](https://hub.docker.com/r/pupilfirst/pupilfirst). We can simply pull the image from Docker Hub and push it to the Heroku Container Registry for use on Heroku.

```bash
docker pull pupilfirst/pupilfirst
```

The above command will pull the image from the Docker Hub to our local system. If we run `docker images` we should see something like this:

```
REPOSITORY              TAG       IMAGE ID       CREATED      SIZE
pupilfirst/pupilfirst   latest    3040b3b09992   5 days ago   572MB
```

Now that we have the Docker image on our system, all we need to do is to push the image to Heroku.

First we will tag the image as per Heroku's specification: `registry.heroku.com/<app>/<process-type>`. Here `<app>` is the name of our Heroku app and `<process-type>` is the type of process we want to run using this image. In Heroku there are three primary process types:

- Web dynos: They receive HTTP traffic from routers and typically run web servers.
- Worker dynos: They execute anything else, such as background jobs, queuing systems, and timed jobs.
- One-off dynos: They are temporary, and not part of an ongoing dyno formation.

In our case we want to run both the `web` and `worker` process types using the same image. Pupilfirst LMS's Docker images are configured to detect Heroku's dyno type and automatically launch the correct process.

Let's start by tagging our Docker image for use in both `web` and `worker` dyno types:

```bash
docker tag pupilfirst/pupilfirst registry.heroku.com/<app>/web
docker tag pupilfirst/pupilfirst registry.heroku.com/<app>/worker
```

In the above command, replace `<app>` with your Heroku application's name. Then we will push the image to Heroku Container Registry, the URL used here will be the same as the tag we just added to the Docker image.

```bash
docker push registry.heroku.com/<app>/web
docker push registry.heroku.com/<app>/worker
```

Now that we have our images in the Heroku Container Registry, now all we need to do it to release the image to our app. We can release both the `web` and `worker` images in one command:

```bash
heroku container:release web worker --app <app>
```

At this point, your web and worker processes should be up and running. However, the application's database is still _empty_. We need to set that up next.

## Set up the database

Before proceeding, make sure that you've provisioned a PostgreSQL add-on to your application. Once provisioned, Heroku would already have _created_ the database for us inside PostgreSQL, so we can go ahead and load the structure of the database from the application's _schema_.

```bash
heroku run "bundle exec rails db:schema:load" --app <app>
```

Once the DB structure is in place, we can seed some values into the database to make setup easier:

```bash
heroku run "bundle exec rails db:seed" --app <app>
```

### Set up a user to sign in with

At this point, the database should have a single user in it: `admin@example.com`. You should set a password for this
user and use it to gain access to the platform.

We'll start a Rails console on Heroku to do so:

```bash
heroku run "bundle exec rails console" --app <app>
```

Once the console is ready, find and update the user entry.

```ruby
user = User.find_by(email: 'admin@example.com')

user.update!(
  password: 'a secure password',
  password_confirmation: 'a secure password',
)
```

You **should** discard this user, later, via the school administration interface once you've enrolled yourself as a school
admin.

### Set a primary domain

Let's inform the application about its domain address. On the Rails console, run:

```ruby
School.first.domains.create!(fqdn: 'my-app-name.herokuapp.com', primary: true)
```

Change `my-app-name.herokuapp.com` to match your actual fully qualified domain name.

You can have more than one domain responding to requests, so you can use this same process to add more custom domains. Make sure that only one domain is set to `primary: true`. This primary domain will be used to generate URLs in emails and such.

## Try visiting the LMS's URL

Now, if you visit the web address for your Heroku app, you should see the homepage for your school. You should also be able to sign in as `admin@example.com` to start working on your school.

## Scheduling periodic tasks

There are a few tasks that must be run scheduled to run periodically; this can be done using Heroku's [Scheduler](https://devcenter.heroku.com/articles/scheduler) add-on.

- `cleanup` (daily) - used to perform general database cleanup of orphaned entries.
- `daily_digest` (daily) - sends a daily digest of updates via email to all users in the school.
- `notify_and_delete_inactive_users` (daily) - checks for inactive users, notifies those who are a month away from deletion, and deletes notified users after the configured time.

1. Add the _Scheduler_ add-on on Heroku.

   ```bash
   heroku addons:create scheduler:standard
   ```

2. Open the _Scheduler_ dashboard for your app.

   ```bash
   heroku addons:open scheduler
   ```

3. Add the the jobs using the _Add Job_ option in the dashboard. Schedule these rake tasks to run as per the requirements noted above.

## Troubleshooting

If you're encountering crashes or errors, the first thing you should do is check the server logs. You can watch the Rails `production.log` file on Heroku by using the `logs` command:

```bash
heroku logs --tail --app <app>
```
