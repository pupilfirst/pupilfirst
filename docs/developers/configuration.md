---
id: configuration
title: Configuration
sidebar_label: Configuration
---

Pupilfirst LMS is configured by setting environment variables. The following list of environment variables are divided into _Essential_ and _Optional_ environment variables. All essential variables must be set for the application to function properly.

## Essential

### Basic configuration

```bash
# Set to your web application's Fully Qualified Domain Name (FQDN).
ASSET_HOST=https://fully-qualified.domain-name.com

# URL to PostgreSQL database.
DATABASE_URL=postgresql://username:password@host:port/database?sslmode=require

# This will be the default email address used in the 'from' field of outbound emails.
DEFAULT_SENDER_EMAIL_ADDRESS=noreply@domain-name.com

# Languages that are available, and the default language.
I18N_AVAILABLE_LOCALES=en,ru
I18N_DEFAULT_LOCALE=en

RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true

# Generate this value from the command line using `rake secret`.
SECRET_KEY_BASE=generate_using_rails_secret
```

### Sending emails with Postmark

```
POSTMARK_API_TOKEN
POSTMARK_HOOK_ID
POSTMARK_HOOK_SECRET
```

To set up Pupilfirst to send transactional emails, you'll need to [create a Postmark account](https://postmarkapp.com/manual), and add the `POSTMARK_API_TOKEN` environment variable with your account's API token.

Before proceeding with the next step, finish [Postmark's account approval process](https://postmarkapp.com/support/article/1084-how-does-the-account-approval-process-work), and make sure that outbound emails (such as sign-in emails) to domains other than your own are working.

#### Setting up the _bounce_ and _spam complaint_ webhook

You can configure Pupilfirst to block sending of emails to user addresses that are hard-bouncing, or where the users have complained that messages are spam. To do so, create a webhook once you've gotten outbound mails working.

1. You can create webhooks by logging into your Postmark account, and heading to _Servers > Your Server > Your Message Stream > Webhooks > Add Webhook_.
2. The webhook should be pointed to: `https://your.school.domain/users/email_bounce`.
3. The _Bounce_ and _Spam Complaint_ options should be the events that are selected - there is no need to include the message content.
4. Add some _Basic auth credentials_, and use those values to configure the `POSTMARK_HOOK_ID` and `POSTMARK_HOOK_SECRET` environment variables on Heroku.

### File storage using AWS

```
AWS_ACCESS_KEY_ID=access_key_id_from_aws
AWS_SECRET_ACCESS_KEY=secret_access_key_from_aws
AWS_REGION=bucket_region_name
AWS_BUCKET=bucket_name_from_aws
```

To allow users to upload files, and to retrieve them, we'll use AWS's S3. The service [has extensive documentation](https://docs.aws.amazon.com/AmazonS3/latest/dev/Welcome.html).

The following process is overly simplified, but is what you'll broadly need to do:

1. Create a new S3 bucket to store uploaded files.
2. Set up an IAM user with read & write permissions on the bucket.
3. Configure Pupilfirst to use the newly created bucket using the correct credentials. Refer `AWS_*` keys in `example.env`.

### Google Recaptcha

```
RECAPTCHA_V3_SITE_KEY
RECAPTCHA_V3_SECRET_KEY
RECAPTCHA_V2_SITE_KEY
RECAPTCHA_V2_SECRET_KEY
```

Sign up for Google's Recaptcha service and generate both V3 (invisible) and V2 (visible) by supplying your application's FQDN.

### Web push notifications

```
VAPID_PUBLIC_KEY
VAPID_PRIVATE_KEY
```

To enable push notifications you will have to set mandatory environment variable `VAPID_PUBLIC_KEY` and `VAPID_PRIVATE_KEY`.

You can generate the keys by running the following commands on a Rails console:

```ruby
vapid_key = Webpush.generate_key

# VAPID_PUBLIC_KEY
vapid_key.public_key

# VAPID_PRIVATE_KEY
vapid_key.private_key
```

Detailed Documentation: https://github.com/zaru/webpush#generating-vapid-keys

### Defaults

Some essential variables (not listed elsewhere in this document) have defaults which should be changed depending on your requirements. The following are their defaults for the production environment:

```bash
# Timeout for general web requests.
SLOWPOKE_TIMEOUT=15

# The port that the server will listen on to receive requests.
PORT=3000
```

## Optional

### Cloudfront

```bash
# Bas64 encoded private key used for generating the cloudfront public key
CLOUDFRONT_PRIVATE_KEY_BASE_64_ENCODED=cloudfront_private_key_from_aws

# Cloudfront hostname
CLOUDFRONT_HOST=cloudfront_host_from_aws

# Cloudfront public key pair ID
CLOUDFRONT_KEY_PAIR_ID=cloudfront_key_pair_id_from_aws

# An integer in seconds used to compute the expiry time for the signed URL
CLOUDFRONT_EXPIRY=expiry_in_seconds
```

To enable delivery of user-uploaded files through a CDN, you will have to set Cloudfront environment variables.

1. [Create a Cloudfront public key](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-creating-signed-url-canned-policy.html) to generate signed URLs with canned policy.
2. [Create a cloudfront distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html) for accessing the private AWS S3 contents with signed URLs.
3. Set up the required environment variables.

### Sign in with OAuth

```
GOOGLE_OAUTH2_CLIENT_ID
GOOGLE_OAUTH2_CLIENT_SECRET
FACEBOOK_KEY
FACEBOOK_SECRET
GITHUB_KEY
GITHUB_SECRET
DISCORD_KEY
DISCORD_SECRET
SSO_DOMAIN
```

> **Warning:** These instructions, for signing in with OAuth, are _rough_. This feature will need to be made configurable before its documentation can be expanded / re-written.

1. Create OAuth apps for Google, Github, and Facebook, setting the redirect URI for each of these apps to `https://your.school.domain/users/auth/SERVICE/callback`, where service is one of `github`, `facebook`, or `google_oauth2`.
2. Set credentials for OAuth apps - the required environment variables and listed above, and inside `example.env`.
3. Set the `SSO_DOMAIN` environment variable to your fully qualified domain name (`your.school.domain`, for example).

### Rollbar

```
ROLLBAR_CLIENT_TOKEN
ROLLBAR_SERVER_TOKEN
```

[Rollbar](https://rollbar.com) can be used to monitor both server-side and client-side errors. Because of this, two separate tokens are required:

1. Set `ROLLBAR_SERVER_TOKEN` with your project's `post_server_item` access token.
2. Set `ROLLBAR_CLIENT_TOKEN` with your project's `post_client_item` access token.

You can find both of these tokens by going to your project's **Settings** > **Project Access Tokens**.

### Performance and error monitoring with New Relic

```
NEW_RELIC_LICENSE_KEY
```

To enable performance and error monitoring with [New Relic](https://newrelic.com/), sign up for a New Relic account and configure its credentials using the `NEW_RELIC_LICENSE_KEY` key.

### API rate limiting

```
GRAPH_API_RATE_LIMIT
GRAPH_API_RATE_PERIOD
REDIS_URL
```

At minimum, to enable rate limiting on the API, you need to set the `REDIS_URL` to a Redis connection string. The `_LIMIT` and `_PERIOD` keys default to 300 requests per 60 seconds.

### Direct Upload to Vimeo

```
VIMEO_ACCESS_TOKEN
VIMEO_ACCOUNT_TYPE
```

To enable direct uploads to a Vimeo account from the curriculum editor, add the `VIMEO_ACCESS_TOKEN` and `VIMEO_ACCOUNT_TYPE` (`basic`, `plus`, `pro`, `business`, `premium`) environment variables.

Make sure that the access token has the following scopes enabled:

- `private`
- `create`
- `edit`
- `upload`
- `video_files`

> Note: You cannot upload private videos if your Vimeo account type is `basic`.

### Alerts for repeated submission rejection by bots

If you're using the API to review and reject submissions, it's possible that students may repeatedly submit values that get rejected by automation. To be notified of such events, so that you can manually intervene, set the following two environment variables to notify all _human_ coaches in a course about a bot repeatedly rejecting submissions.

```
# Comma-separated IDs of bot coaches (`faculty` table) members used to review submissions.
BOT_EVALUATOR_IDS=1,2,3

# Every n-th rejected submission by a bot will trigger an email to all non-bot coaches in a course.
BOT_EVALUATOR_REPEAT_REJECTION_ALERT_THRESHOLD=4
```

To deactivate this feature, simply avoid setting the `BOT_EVALUATOR_IDS` environment variable, or set `BOT_EVALUATOR_REPEAT_REJECTION_ALERT_THRESHOLD` to zero.
