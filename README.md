## README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
  * MRI 2.0+
* System dependencies
  * imagemagick
  * postgresql
  * rubygems
  * bundler gem

* Configuration
  * setup database.yml for postgresql
  * copy example.env to .env and set the variables as required

* Database creation
  * bundle exec rake db:create

* Database initialization
  * bundle exec rake db:setup

* How to run the test suite
  * bundle exec rspec spec

* Services (job queues, cache servers, search engines, etc.)
  * job query is managed by sucker_punch which runs in rails process processing between requests
  * can be switched to Resque easily

* Deployment instructions

  Deployment is taken care by git push(on master/development) using circlCI hook
  Specific instructions can be found in circle.yml
  for manual push to heroku use
  * config .git/config

        [remote "heroku"]
          url = git@heroku.com:svapp.git
          fetch = +refs/heads/*:refs/remotes/heroku/*
        [remote "staging"]
          url = git@heroku.com:svapp-staging.git
          fetch = +refs/heads/*:refs/remotes/staging/*

  * `git push heroku master` will push to production (svlabs.in)
  * `git push heroku staging` will push to staging (staging.svlabs.in)

* Web resources considered for dev

  * http://matthewlehner.net/rails-api-testing-guidelines/
  * https://github.com/joshbuddy/jsonpath
  * http://pivotallabs.com/api-versioning/


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.

* Known Issues

  * Deprecation Warnings in rspec caused by json_spec. Gem needs to be updated
  * n + 1 query optimization need to be added as required.
  *
