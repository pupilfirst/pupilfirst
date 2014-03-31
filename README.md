# SVLabs Web + API

## Dependencies
*  Ruby version - MRI 2.0+
*  imagemagick
*  postgresql

## Configuration
*  Setup database.yml for postgresql

## Database setup
    $ bundle exec rake db:setup

## Testing
    bundle exec rake spec

## Services
  * Job query is managed by the sucker_punch gem, which runs in Rails process, processing between requests. This can be
  switched to Resque easily.

## Deployment
Deployment is taken care by git push(on master/development) using circlCI hook.
Specific instructions can be found in circle.yml

For manual push to heroku use:

Edit ``.git/config``:

      [remote "heroku"]
        url = git@heroku.com:svapp.git
        fetch = +refs/heads/*:refs/remotes/heroku/*
      [remote "staging"]
        url = git@heroku.com:svapp-staging.git
        fetch = +refs/heads/*:refs/remotes/staging/*

Then:

* `git push heroku master` will push to production (svlabs.in)
* `git push heroku staging` will push to staging (staging.svlabs.in)

## Web resources considered for dev
*  http://matthewlehner.net/rails-api-testing-guidelines/
*  https://github.com/joshbuddy/jsonpath
*  http://pivotallabs.com/api-versioning/

## Known Issues
*  Deprecation Warnings in rspec caused by json_spec. Gem needs to be updated
*  n + 1 query optimization need to be added as required.
