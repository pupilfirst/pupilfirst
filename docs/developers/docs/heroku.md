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

Begin by [signing up on Heroku](https://signup.heroku.com), and familiarizing yourself with [how Ruby apps run on Heroku](https://devcenter.heroku.com/articles/getting-started-with-ruby).

### Set up the Heroku app

1. Create a new Heroku app, to which we'll deploy Pupilfirst.
2. [Configure your new Heroku app](https://devcenter.heroku.com/articles/config-vars) using environment variables.
   1. Add configuration for [the file storage service](#file-storage-using-aws).
   2. Add configuration for [the email service](#sending-emails-with-postmark).
   3. Set `ASSET_HOST` to your app's fully qualified domain name (FQDN), which should look like `my-app-name.herokuapp.com`.

   There are more optional features that you can enable - read through the sections below.
3. Add the new Heroku app [as a git remote](https://devcenter.heroku.com/articles/git#for-an-existing-heroku-app).
4. Push the repository to your Heroku app: `git push heroku master`.

This should leave you with a Heroku app that already has an empty Postgres database attached to it.

### Set up the database

Set up the database using the schema, and seed a few basic entries into the database. We'll use the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) to execute the Rails tasks on the production environment.

```bash
heroku run rails db:schema:load
heroku run rails db:seed
```

### Set up a user to sign in with

At this point, the database should have a single user in it: `admin@example.com`. You should set a password for this
user and use it to gain access to the platform.

We'll start a Rails console on Heroku to do so:

```bash
heroku run console
```

Once the console is ready, find and update the user entry.

```ruby
user = User.find_by(email: 'admin@example.com')
user.update!(password: 'a secure password', password_confirmation: 'a secure password')
```

You **should** discard this user, later, via the school administration interface once you've enrolled yourself as a school
admin.

### Set a primary domain

Let's inform the application about its domain address. On the Heroku console, run:

```ruby
School.first.domains.create!(fqdn: 'my-app-name.herokuapp.com', primary: true)
```

Change `my-app-name.herokuapp.com` to match your actual fully qualified domain name.

You can have more than one domain responding to requests, so you can use this same process to add more custom domains.
Make sure that only one domain is set to `primary: true`. This primary domain will be used to generate URLs in emails
and such.

### Start the _dynos_

Finally, start the web and worker dynos on Heroku.

```bash
heroku ps:scale web=1 worker=1
```

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
3. Add the the jobs using the _Add Job_ option in the dashboard. Schedule both tasks to run as per the requirements noted above.

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

## Performance monitoring with Skylight

To enable performance monitoring with [Skylight](https://www.skylight.io/), sign up for a Skylight account and configure its credentials using the `SKYLIGHT_AUTHENTICATION` key.

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

## Troubleshooting

If you're encountering crashes or errors, the first thing you should do is check the server logs. You can watch the Rails `production.log` file on Heroku by using the `logs` command:

```bash
heroku logs --tail
```
