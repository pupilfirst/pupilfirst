---
id: heroku
title: Deploying to Heroku
sidebar_label: Heroku
---

## Before deploying

Start by making sure that you've gone through [our notes of some things to consider before deploying](before_deploying).

## Why Heroku?

Heroku is a [PaaS](https://en.wikipedia.org/wiki/Platform_as_a_service) provider that takes care of all network and hardware maintenance requirements for running web applications.

It also makes the deployment and update process extremely simple when compared to the use of traditional [IaaS](https://en.wikipedia.org/wiki/Infrastructure_as_a_service) providers.

## Steps on Heroku

Begin by [signing up on Heroku](https://signup.heroku.com), and familiarizing yourself with [how containerized apps run on Heroku](https://devcenter.heroku.com/articles/container-registry-and-runtime).

### Set up the Heroku app

1. Create a new Heroku app, to which we'll deploy Pupilfirst.
2. Attach a PostgreSQL database as an add-on to your Heroku application. You can do this from the _Resources_ tab on Heroku.
3. [Configure your new Heroku app](https://devcenter.heroku.com/articles/config-vars) using environment variables.

   Make sure that you set up all required environment variables - we've documented these separately since they're common to different deployment targets.

   Additionally, on Heroku, make sure that set the following variables are also set:

   ```
   RAILS_ENV=production
   RAILS_LOG_TO_STDOUT=true
   RAILS_SERVE_STATIC_FILES=true
   TINI_SUBREAPER=true
   ```

## Deployment using Docker

The Heroku Container Registry allows us to deploy our Docker images to Heroku. To access the Heroku Container Registry, we first need to log into it:

```bash
heroku container:login
```

Once we are logged in we can push our image to the registry and deploy our app. Pupilfirst maintains [official images on Docker Hub](https://hub.docker.com/r/pupilfirst/pupilfirst). We can simply pull the image from Docker Hub and push it to the Heroku Container Registry for use on Heroku.

```bash
docker pull pupilfirst/pupilfirst
```

The above command will pull the image from the Docker Hub to our local system. If we run `docker images` we should see something like this:

```bash
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
heroku run "bundle exec rails db:schema:load" --app pupilfirst-lms-test-220706
```

Once the DB structure is in place, we can seed some values into the database to make setup easier:

```bash
heroku run "bundle exec rails db:seed" --app pupilfirst-lms-test-220706
```

### Set up a user to sign in with

At this point, the database should have a single user in it: `admin@example.com`. You should set a password for this
user and use it to gain access to the platform.

We'll start a Rails console on Heroku to do so:

```bash
heroku run "bundle exec rails console" --app pupilfirst-lms-test-220706
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

## Try visiting the LMS's URL

Now, if you visit the web address for your Heroku app, you should see the homepage for your school. You should also be able to sign in as `admin@example.com` to start working on your school.

### Scheduling periodic tasks

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

## File storage using AWS

To allow users to upload files, and to retrieve them, we'll use AWS's S3. The service [has extensive documentation](https://docs.aws.amazon.com/AmazonS3/latest/dev/Welcome.html).

The following process is overly simplified, but is what you'll broadly need to do:

1. Create a new S3 bucket to store uploaded files.
2. Set up an IAM user with read & write permissions on the bucket.
3. Configure Pupilfirst to use the newly created bucket using the correct credentials. Refer `AWS_*` keys in `example.env`.

## Sending emails with Postmark

To set up Pupilfirst to send transactional emails, you'll need to [create a Postmark account](https://postmarkapp.com/manual), and add the `POSTMARK_API_TOKEN` environment variable with your account's API token.

Before proceeding with the next step, finish [Postmark's account approval process](https://postmarkapp.com/support/article/1084-how-does-the-account-approval-process-work), and make sure that outbound emails (such as sign-in emails) to domains other than your own are working.

### Setting up the _bounce_ and _spam complaint_ webhook

You can configure Pupilfirst to block sending of emails to user addresses that are hard-bouncing, or where the users have complained that messages are spam. To do so, create a webhook once you've gotten outbound mails working.

1. You can create webhooks by logging into your Postmark account, and heading to _Servers > Your Server > Your Message Stream > Webhooks > Add Webhook_.
2. The webhook should be pointed to: `https://your.school.domain/users/email_bounce`.
3. The _Bounce_ and _Spam Complaint_ options should be the events that are selected - there is no need to include the message content.
4. Add some _Basic auth credentials_, and use those values to configure the `POSTMARK_HOOK_ID` and `POSTMARK_HOOK_SECRET` environment variables on Heroku.

## Performance and error monitoring with New Relic

To enable performance and error monitoring with [New Relic](https://newrelic.com/), sign up for a New Relic account and configure its credentials using the `NEW_RELIC_LICENSE_KEY` key.

## Adding Memcached Cloud as cache store for API rate limiting

You need to add a cache store to handle API rate limiting in the application.

1. Add the _Memcached Cloud_ add-on on Heroku.
   ```bash
   heroku addons:create memcachedcloud
   ```
2. Configure the `GRAPH_API_RATE_LIMIT` environment variable on Heroku to the permitted requests per second.

## Signing in with OAuth

> **Warning:** These instructions, for signing in with OAuth, are _rough_. This feature will need to be made configurable before its documentation can be expanded / re-written.

1. Create OAuth apps for Google, Github, and Facebook, setting the redirect URI for each of these apps to `https://your.school.domain/users/auth/SERVICE/callback`, where service is one of `github`, `facebook`, or `google_oauth2`.
2. Set credentials for OAuth apps using environment variables (find required keys in `example.env`).
3. Set the `SSO_DOMAIN` environment variable to your fully qualified domain name (`your.school.domain`, for example).

## Direct Upload to Vimeo

To enable direct uploads to a Vimeo account from the curriculum editor, add the `VIMEO_ACCESS_TOKEN` and `VIMEO_ACCOUNT_TYPE` (`basic`, `plus`, `pro`, `business`, `premium`) environment variables.

Make sure that the access token has the following scopes enabled:

- `private`
- `create`
- `edit`
- `upload`
- `video_files`

> Note: You cannot upload private videos if your Vimeo account type is `basic`.

## Webpush Notifications

To enable webpush notification you will have to set mandatory environment variable `VAPID_PUBLIC_KEY` and `VAPID_PRIVATE_KEY`.

You can generate the keys by running the following on the server. ([Detailed Doc](https://github.com/zaru/webpush#generating-vapid-keys))

```
vapid_key = Webpush.generate_key

#VAPID_PUBLIC_KEY
vapid_key.public_key


#VAPID_PRIVATE_KEY
vapid_key.private_key
```

## Content Delivery Network

To enable delivery of user-uploaded files through a CDN, you will have to set Cloudfront environment variables.

1. [Create a Cloudfront public key](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-creating-signed-url-canned-policy.html) to generate signed URLs with canned policy.
2. [Create a cloudfront distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html) for accessing the private AWS S3 contents with signed URLs.
3. Set up the required environment variables:

   ```
   # Bas64 encoded private key used for generating the cloudfront public key
   CLOUDFRONT_PRIVATE_KEY_BASE_64_ENCODED=cloudfront_private_key_from_aws

   # Cloudfront hostname
   CLOUDFRONT_HOST=cloudfront_host_from_aws

   # Cloudfront public key pair ID
   CLOUDFRONT_KEY_PAIR_ID=cloudfront_key_pair_id_from_aws

   # An integer in seconds used to compute the expiry time for the signed URL
   CLOUDFRONT_EXPIRY=expiry_in_seconds
   ```

## Troubleshooting

If you're encountering crashes or errors, the first thing you should do is check the server logs. You can watch the Rails `production.log` file on Heroku by using the `logs` command:

```bash
heroku logs --tail --app <app>
```
