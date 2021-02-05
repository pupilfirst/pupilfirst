---
id: background_jobs
title: Background Jobs
sidebar_label: Background Jobs
---

## Running Background Jobs

Background jobs are written using [Rails ActiveJob](https://guides.rubyonrails.org/active_job_basics.html), and deferred
using [delayed_job](https://github.com/collectiveidea/delayed_job) in the production environment.

By default, the development and test environment run jobs in-line with a request. If you've manually configured the
application to defer them instead, you can execute the jobs with:

    rake jobs:workoff
