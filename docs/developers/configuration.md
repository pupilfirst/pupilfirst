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
RAILS_SERVE_STATIC_FILES=true

# Generate this value from the command line using `rake secret`.
SECRET_KEY_BASE=generate_using_rails_secret
```

### Sending transactional email (Postmark or SMTP)

The production email transport is selected by `MAIL_DELIVERY_METHOD`. If unset, it
defaults to `postmark` for backward compatibility. Mailers and `deliver_later`
jobs are unchanged; only Rails Action Mailer's delivery configuration varies.

**Existing Postmark deployments (default)**

~~~bash
MAIL_DELIVERY_METHOD=postmark
POSTMARK_API_TOKEN=your_postmark_token
POSTMARK_HOOK_ID=your_webhook_username
POSTMARK_HOOK_SECRET=your_webhook_password
~~~

To send transactional emails using Postmark, [create an account](https://postmarkapp.com/manual),
complete Postmark's approval process, and ensure that outbound email to external
domains works.

**SMTP alternative (including an independently operated relay)**

~~~bash
MAIL_DELIVERY_METHOD=smtp
SMTP_ADDRESS=mail.example.org
SMTP_PORT=587
SMTP_DOMAIN=example.org
SMTP_USERNAME=mailer@example.org
SMTP_PASSWORD=your_smtp_password
SMTP_AUTHENTICATION=plain
~~~

SMTP username/password and authentication mode may be omitted together for a
secured, unauthenticated internal relay. Supported authenticated modes:
`plain` (default), `login` and `cram_md5`. The application requires STARTTLS
and fails if the server does not offer it; configure a valid TLS certificate.
This setup is for STARTTLS submission, typically port 587, **not implicit TLS
on port 465**. Never disable TLS verification for a production deployment.
Credentials must be supplied at runtime as secrets, not baked into Docker
images. Missing/invalid SMTP configuration fails at production boot.

Unlike Postmark, SMTP alone does not supply a standard asynchronous bounce
webhook. Existing `BounceReport` suppression still works; an SMTP operator
must additionally ingest **permanent** bounces and spam complaints from their
relay to keep suppression current. The shared server-side ingestion primitive is
`EmailBounces::RecordService.call(email:, type:)`, accepting only
`HardBounce` or `SpamComplaint`. This change does **not** add a generic
public webhook, and it does not classify temporary/deferred failures as bounces.
A provider-specific authenticated adapter needs to be tested before claiming
complete operational parity with Postmark.

**Production validation before switching**

1. Use a test relay with STARTTLS, or a production-like independent relay.
   Mailpit's default port 1025 does not offer STARTTLS unless TLS is configured.
2. Confirm the Docker asset build succeeds without `POSTMARK_API_TOKEN`.
3. Send actual sign-in, password-reset, enrollment, feedback and deletion email,
   including at least one `deliver_later` path processed by Delayed Job.
4. Test both the default `DEFAULT_SENDER_EMAIL_ADDRESS` and a confirmed
   school-specific From address. Check relay policy, SPF/DKIM and DMARC alignment
   and actual inbox delivery. Successful SMTP submission is not proof of delivery.
5. Confirm existing `BounceReport` rows still prevent mail across schools,
   including sign-in and password-reset. Confirm real hard-bounce and complaint
   events can be recorded from the chosen SMTP relay.
6. Preserve Postmark delivery as rollback: set `MAIL_DELIVERY_METHOD=postmark`
   and restore valid Postmark credentials. Do not retry a failed SMTP send through
   a different provider automatically; that can duplicate transactional emails.

#### Postmark bounce and spam-complaint webhook

For a Postmark deployment, you can configure Pupilfirst to block sending to
addresses that hard-bounce or complain. This is recommended for reliable
operational delivery:

1. In Postmark, go to _Servers > Your Server > Your Message Stream > Webhooks_.
2. Set the webhook URL to `https://your.school.domain/users/email_bounce`.
3. Select _Bounce_ (permanent hard-bounce) and _Spam Complaint_ events only;
   do not include email message content.
4. Configure HTTP Basic authentication and set `POSTMARK_HOOK_ID` and
   `POSTMARK_HOOK_SECRET` at runtime.

For the work plan and evidence still needed for DPGA indicator 4, see
[email provider independence plan](email-provider-independence-plan.md).

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

### Google reCAPTCHA

```
RECAPTCHA_V3_SITE_KEY
RECAPTCHA_V3_SECRET_KEY
RECAPTCHA_V2_SITE_KEY
RECAPTCHA_V2_SECRET_KEY
RECAPTCHA_DISABLED=false
```

Sign up for Google's reCAPTCHA service and generate both V3 (invisible) and V2 (visible) by supplying your application's FQDN.

:::note

If you wish to avoid using Google's reCAPTCHA ([not recommended](https://support.google.com/recaptcha/answer/6080904?hl=en)), you can set `RECAPTCHA_DISABLED` to `true`. This will disable the use of reCAPTCHA for public forms.

:::

### Web push notifications

```
VAPID_PUBLIC_KEY
VAPID_PRIVATE_KEY
```

To enable push notifications you will have to set mandatory environment variable `VAPID_PUBLIC_KEY` and `VAPID_PRIVATE_KEY`.

You can generate the keys by running the following commands on a Rails console:

```ruby
vapid_key = WebPush.generate_key

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

### Setting up AWS CloudFront as a CDN for Private AWS Bucket

This section will guide you through the process of setting up AWS CloudFront to serve assets from a private AWS bucket.

#### Step 1: Creating a CloudFront Distribution

1. Navigate to the **AWS Console** and select the **CloudFront** service.
2. Click on **Create Distribution**.
3. Select your desired AWS bucket from the list as the **Origin**.

#### Step 2: Configuring Origin Access

During the setup, follow the configuration as shown below.

![Screenshot of CloudFront origin settings](../assets/developers/cloudfront_origin.png)

**Note**: On your first setup, ensure to select **Yes, update the policy**.

#### Step 3: Configuring Behaviours

For the most part, you can retain the default settings. However, the section below requires your attention. Refer to the screenshot below for more clarity:

![Screenshot of CloudFront origin settings](../assets/developers/cloudfront_behaviour.png)

#### Step 4: Creating Key Group and Public Key

Click on **Create key group** to generate a new group. To this group, you need to add a new public key. This key will be used to generate signed URLs to your resources in the bucket.

For detailed instructions on creating public keys and key groups, refer to the [AWS documentation on creating CloudFront key pairs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html#private-content-creating-cloudfront-key-pairs).

#### Step 5: Setting Environment Variables in your LMS application

You need to set the following environment variables:

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

You can obtain the `cloudfront_host_from_aws` from the distribution you created. The `cloudfront_key_pair_id_from_aws` can be found in the key group window. It will contain the key pair id of the public key you added in the previous step.

To set `CLOUDFRONT_PRIVATE_KEY_BASE_64_ENCODED`, follow the steps below:

1. Copy the contents of the `private_key.pem` file you obtained while creating the keys in Step 4.
2. Open the Rails console and encode the contents using `Base64.urlsafe_encode64(test)`.
3. Set the obtained value as the environment variable.

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

### Scheduled jobs

If you're setting up a scheduler process with `PROCESS_TYPE=scheduler`, you can customize the schedule used to run these rake tasks:

```
# This is the default configuration, which will run each task daily at midnight, server-time.
SCHEDULE_CLEANUP="0 0 0 * * * *"
SCHEDULE_DAILY_DIGEST="0 0 0 * * * *"
SCHEDULE_NOTIFY_AND_DELETE_INACTIVE_USERS="0 0 0 * * * *"
```

Documentation of the schedule's format can be [found in supercronic's README file](https://github.com/aptible/supercronic?tab=readme-ov-file#crontab-format).

### Session-related

These values, in minutes, controls how long the corresponding one-time links sent to users remains active.

```
RESET_PASSWORD_TOKEN_TIME_LIMIT=15
LOGIN_TOKEN_TIME_LIMIT=15
```

You can also configure the maximum number of attempts allowed for OTPs.

```
INPUT_TOKEN_MAX_ATTEMPTS=5
```

## School Specific Configuration

LMS allows you to configure specific settings for a school using various integrations such as Discord, Email Sender Signature, Vimeo, and Github. The following documentation describes how to set up the configurations field in school model.

### Email Sender Signature Configuration

To set up the Email Sender Signature integration, provide the following keys in the email_sender_signature object:

- name: The name of the email sender.
- email: The email address of the email sender.
- confirmed_at: The date and time when the email address was confirmed (in ISO 8601 format).
  Example:

```json
"email_sender_signature": {
  "name": "John Doe",
  "email": "john.doe@example.com",
  "confirmed_at": "2023-05-10T00:00:00Z"
}
```

### Vimeo Configuration

To set up the Vimeo integration, provide the following keys in the vimeo object:

- account_type: The Vimeo account type (e.g., "basic", "plus", "pro", "business", or "premium").
- access_token: The Vimeo API access token.

Example

```json
"vimeo": {
  "account_type": "pro",
  "access_token": "your_access_token"
}
```

### Github Configuration

To set up the Github integration, provide the following keys in the github object:

- access_token: The Github API access token.
- organization_id: The Github organization ID.
- default_team_id: The default Github team ID to be added to a repository.
  Example:

```json
"github": {
  "access_token": "your_access_token",
  "organization_id": "your_organization_id",
  "default_team_id": "your_default_team_id"
}
```

### General Options

1. disable_primary_domain_redirection: Set this to true if you want to disable primary domain redirection. Default is false.

2. delete_inactive_users_after: Set the number of days after which inactive users should be deleted. For example, 30 would delete inactive users after 30 days.

Example:

```json
"disable_primary_domain_redirection": true,
"delete_inactive_users_after": 30
```

> All of these configurations are optional. You can provide any combination of these configurations in the school configurations field.

3. change the default currency: Set the default currency for the school. Default is INR.

```json
"default_currency": "USD"
```

## Development

These are development-specific environment variables, which default to the values given below.

```
# Which driver to use when running tests. See `rails_helper.rb` for options.
JAVASCRIPT_DRIVER=headless_chrome

# In some environments, such as WSL, it may be useful to disable GPU when running tests.
JAVASCRIPT_DRIVER_DISABLE_GPU=false
```
