---
id: upgrading
title: Upgrading Guide
sidebar_label: Upgrading
---

## Run Migrations

When deploying an updated version of the LMS, please check for any pending [migrations](https://edgeguides.rubyonrails.org/active_record_migrations.html) and run them after deployment. If your deployment target is DigitalOcean, and if you've followed our guide, then the worker process should run migrations automatically when it starts up.

You can enable maintenance mode to prevent users from accessing the LMS while migrations are running. To do this, set the `ENABLE_MAINTENANCE_MODE` environment variable to `true` before deploying the new version. Once the deployment is complete, set the variable back to `false`.

## Breaking changes

These are a list of changes that should be accounted for when upgrading an existing installation of Pupilfirst. If you
encounter any problems while following these instructions, please [create a new issue](https://github.com/pupilfirst/pupilfirst/issues/new/choose)
on our Github repo.

Your current version can be found in the Docker image tag, or in `env.PF_VERSION` in the `.github/workflows/ci.yml` file.

### 2024.2

The previous Discord configuration only required two fields: `server_id` and `bot_token`. The configuration now requires the `bot_user_id` in addition to `server_id` and `bot_token`; [related documentation](https://docs.pupilfirst.com/users/discord_integration) has been updated.

### 2024.1

The recommended method for running scheduled jobs under Docker have changed. We've switched to using a foreground process to manage scheduled jobs; [related documentation](https://docs.pupilfirst.com/developers/digitalocean#components) has been updated.

### 2023.6

This is not a breaking change, but you may want to perform some cleanup since we're upgrading to Rails 7.0, and replacing the use of the _ImageMagick_ library with _libvips_ - a faster, more memory-efficient image processing library which is Rails 7's default choice. Because of this change in image processor, image variants created previously using _ImageMagick_ will no longer be used.

```rb
# Run this in the `production` Rails console to delete old variants.
ActiveStorage::VariantRecord.destroy_all
```

New variants will be created using _libvips_ when requests are made for them.

### 2023.5

This version removes the concept of a failure grade for submission reviews. You can either reject a submission or give a passing grade. The pass_grade field of evaluation_criterion table will be removed and so if you are using GraphQL API to create EvaluationCriterion, you need not pass pass_grade as a parameter. Also if you are using GraphQL API to reject or fail a submission you need to call the `createGrading` mutation without any `grades` parameter.

### 2023.4

This version introduces a fundamental shift in our course structure, decoupling student progress tracking from course levels. We're introducing 'milestones' as a replacement for levels to track progress and adjusting several functionalities accordingly, including student progress reporting, student distribution, and more. This change is not backwards compatible. This is the first phase of a multi-phase rollout of the pages feature to compose course content and keeping assignments independent of the content.

### 2023.3

This update addresses few security vulnerabilities in our platform of medium severity. It introduces enhanced security measures, including mandatory password confirmation for email changes, authentication for new password setting, and discreet user presence disclosure. It's vital for all users to upgrade to version 2023.3 to safeguard their accounts effectively.

### 2023.2

This version renames the `founders` table to `students` and updates all related usages throughout the codebase. For most installations of Pupilfirst LMS, this should be a seamless upgrade. However, if you've made customizations or have used any internal APIs, you should check for any references to `founders` and update them to `students`.

### 2023.1

This version merges the `conclusion` with `status` in the `submission_reports` table. This change is not backwards compatible. If you are using the GraphQL API, you will need to ensure that `submissionReports` query is called with the `status` argument instead of `conclusion`.

### 2022.4

This version adds a `completed_at` attribute to students. This attribute will be used to determine if a student has completed a course. After upgrading, you should run the following script via the Rails console to set the `completed_at` attribute for all eligible students:

```rb
Founder
  .all
  .each_with_object(nil) do |student, _x|
    # Get the latest submission for each student.
    latest_submission =
      student.latest_submissions.order("created_at DESC").first

    # If a student has no submission, skip.
    if latest_submission.present? &&
         TimelineEvents::WasLastTargetService.new(
           latest_submission,
         ).was_last_target?
      # If the students has a submission, and it was the last target, set `completed_at`
      student.update!(completed_at: latest_submission.created_at)
    end
  end
```

### 2022.3

This version adds support for running multiple cohorts in a course. This version also introduces new pages in admin for managing cohorts and teams along with redesign of a few other pages.

If you are using the GraphQL API, you will need to ensure that `createStudents` mutation is called with the `cohort_id` argument instead of `course_id`.

### 2022.2

This version adds a new start script (`bin/start`) for the LMS that responds to new environment variables `PROCESS_TYPE`, `WORKER_MIGRATE` and `WORKER_SETUP_CRON`. These variables must be set when deploying to DigitalOcean App Platform. When deploying to Heroku, the recommended approach has changed to pushing official Docker images to Heroku's Container Registry, and then releasing these images to dynos. This replaces the older time-consuming, failure-prone build process on Heroku. On Heroku, you'll also need to set a new environment variable - `TINI_SUBREAPER`. Please go through updated deployment documentation for both these platforms for more information.

### 2022.1

This version replaces Skylight with New Relic for application performance monitoring and adds the `NEW_RELIC_LICENSE_KEY` environment variable to authenticate connection with New Relic. The version also replaces `rack-throttle` gem with `rack-attack` for throttling and blocking abusive requests. This change adds environment variables `GRAPH_API_RATE_LIMIT`, `GRAPH_API_RATE_PERIOD` and `REDIS_URL` to set the number of requests, the period of time in seconds and the URL to the Redis database store respectively.

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
