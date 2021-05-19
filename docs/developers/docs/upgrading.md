---
id: upgrading
title: Upgrading Guide
sidebar_label: Upgrading
---

## Run Migrations

When deploying changes from `master` branch, please check for any pending [migrations](https://edgeguides.rubyonrails.org/active_record_migrations.html)
and run them after deployment.

## Breaking changes

These are a list of changes that should be accounted for when upgrading an existing installation of Pupilfirst. If you
encounter any problems while following these instructions, please [create a new issue](https://github.com/pupilfirst/pupilfirst/issues/new)
on our Github repo.

Your current version can be found in `Pupilfirst::Application::VERSION`.

### 2021.3

- Google's Recaptcha has been introduced to protect public-facing forms from automation.
  To enable the use of Recaptcha, [register for access](https://www.google.com/recaptcha),
  and create v3 and v2 (checkbox) keys for your school's domains, and add environment variables
  `RECAPTCHA_V3_SITE_KEY`, `RECAPTCHA_V3_SECRET_KEY`, `RECAPTCHA_V2_SITE_KEY`, and `RECAPTCHA_V2_SECRET_KEY`.

### 2021.2

- List `courses` query is now paginated. This will affect users using the `courses` api.

### 2021.1

- Introduced required environment variable `VAPID_PUBLIC_KEY` and `VAPID_PRIVATE_KEY` to support
  webpush notification.

  You can generate the keys by running the following on the server.

  ```
  vapid_key = Webpush.generate_key

  #VAPID_PUBLIC_KEY
  vapid_key.public_key

  #VAPID_PRIVATE_KEY
  vapid_key.private_key
  ```

### 2020.4

- Introduced required environment variable `GRAPH_API_RATE_LIMIT`, `MEMCACHEDCLOUD_SERVERS`, `MEMCACHEDCLOUD_USERNAME`,
  `MEMCACHEDCLOUD_PASSWORD` to handle API rate limiting. Memcached Cloud add-on needs to be added while hosting on Heroku.

### 2020.3

- Introduced required environment variable `DEFAULT_SENDER_EMAIL_ADDRESS`. Prior to this, the default sender email id
  was assumed to be `noreply@pupilfirst.com`.

### 2020.2

- Introduced required environment variable `AWS_REGION`. Prior to this, the region was assumed to be `us-east-1`; set
  the correct value for your S3 bucket.

### 2020.1

- Initial release.
