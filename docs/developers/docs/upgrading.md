---
id: upgrading
title: Upgrading Guide
sidebar_label: Upgrading
---

## Run Migrations

When deploying an updated version of the LMS, please check for any pending [migrations](https://edgeguides.rubyonrails.org/active_record_migrations.html)
and run them after deployment.

## Breaking changes

These are a list of changes that should be accounted for when upgrading an existing installation of Pupilfirst. If you
encounter any problems while following these instructions, please [create a new issue](https://github.com/pupilfirst/pupilfirst/issues/new/choose)
on our Github repo.

Your current version can be found in `Pupilfirst::Application::VERSION` or in the Docker image tag.

### 2022.0

This version adds the `PREPARE_FOR_PRECOMPILATION` environment variable. If you're building Pupilfirst in production,
this environment variable will need to be set to `true` to allow the Rails asset precompilation step to work properly.

### 2021.5

Markdown editors no longer support the Commonmark standard. Even prior to this version, support for mixing HTML, CSS
and JS into Markdown was spotty because of very strict output sanitization. This means that Commonmark support was
partial. With this change, scripting within Markdown text inputs has been completely disabled.

This means that any stored Markdown text that contained compliant HTML / CSS / JS within prior to this change will now
be _escaped_ and displayed as plaintext in the rendered output.

This also breaks the `<img align="center">` approach for centering text. Since this method for centering text in HTML
relied on writing HTML within Markdown, it doesn't work anymore. Instead, Markdown's syntax has been extended to support
alignment of text using special markers. Check out the built-in documentation of Markdown for more information.

### 2021.4

Introduced required environment variables `I18N_AVAILABLE_LOCALES` and `I18N_DEFAULT_LOCALE`.

### 2021.3

Google's Recaptcha has been introduced to protect public-facing forms from automation.
To enable the use of Recaptcha, [register for access](https://www.google.com/recaptcha),
and create v3 and v2 (checkbox) keys for your school's domains, and add environment variables
`RECAPTCHA_V3_SITE_KEY`, `RECAPTCHA_V3_SECRET_KEY`, `RECAPTCHA_V2_SITE_KEY`, and `RECAPTCHA_V2_SECRET_KEY`.

### 2021.2

List `courses` query is now paginated. This will affect users using the `courses` API query.

### 2021.1

Introduced required environment variable `VAPID_PUBLIC_KEY` and `VAPID_PRIVATE_KEY` to support webpush notification.

You can generate the keys by running the following on the server.

```
vapid_key = Webpush.generate_key

#VAPID_PUBLIC_KEY
vapid_key.public_key

#VAPID_PRIVATE_KEY
vapid_key.private_key
```

### 2020.4

Introduced required environment variables `GRAPH_API_RATE_LIMIT`, `MEMCACHEDCLOUD_SERVERS`, `MEMCACHEDCLOUD_USERNAME`,
and `MEMCACHEDCLOUD_PASSWORD` to handle API rate limiting. Memcached Cloud add-on needs to be added while hosting on
Heroku.

### 2020.3

Introduced required environment variable `DEFAULT_SENDER_EMAIL_ADDRESS`. Prior to this, the default sender email id
was assumed to be `noreply@pupilfirst.com`.

### 2020.2

Introduced required environment variable `AWS_REGION`. Prior to this, the region was assumed to be `us-east-1`; set
the correct value for your S3 bucket.

### 2020.1

Initial release.
