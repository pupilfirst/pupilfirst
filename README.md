# SVLabs Web + API

## Dependencies
*  Ruby version - MRI 2.0+
*  imagemagick
*  postgresql

## Configuration
*  Setup database.yml for postgresql

## Database setup
    $ bundle exec rake db:setup

## Configuration
  * setup database.yml for postgresql
  * copy example.env to .env and set the variables as required

## Testing
### Manual
To execute all tests manually, run:

    bundle exec rake spec

### RubyMine
To execute tests from within RubyMine, create a shell script `/script/startzeus` (gitignored) with the following
contents and execute it:

    env RUBYLIB=/path/to/RubyMine-6.x/rb/testing/patch/common:/path/to/RubyMine-6.x/rb/testing/patch/bdd zeus start

Then, in RubyMine, go to *Run* >> *Edit Configurations* >> *Defaults* >> *RSpec*, and turn on *Use custom RSpec Runner
Script* and point it to `/script/rspec_runner.rb`.

Now right-click on either the spec directory in the Project view (or any inner directory / file), and choose the
*Run Specs* option.

## Services
Job query is managed by the sucker_punch gem, which runs in Rails process, processing between requests. This can be
switched to Resque easily.

## Deployment
Deployment is taken care by git push(on master/development) using circlCI hook.
Specific instructions can be found in circle.yml

For manual push to heroku use:

Edit ``.git/config``:

      [remote "heroku-staging"]
        url = git@heroku.com:svapp-staging.git
        fetch = +refs/heads/*:refs/remotes/heroku-staging/*
      [remote ""heroku-production"]
        url = git@heroku.com:svapp.git
        fetch = +refs/heads/*:refs/remotes/heroku-production/*

Then:

* `git push heroku-production master:master` will push local master to production (svlabs.in)
* `git push heroku-staging development:master` will push local development to staging (staging.svlabs.in)

## Web resources considered for dev
*  http://matthewlehner.net/rails-api-testing-guidelines/
*  https://github.com/joshbuddy/jsonpath
*  http://pivotallabs.com/api-versioning/

## Known Issues
*  n + 1 query optimization need to be added as required.
*  User of sucker_punch may not be best choice, migration to Resque with additional working is recommended
*  Currently Email are sent during the request, moving them to background process can optimize alot.

## Code quirks
* Mostly uses rspec request specs for integration test. Model, Controller specs are sparingly written.
* Most of the code written post March 20th, 2014 has not been tested to fullest extent. One might wanna start from there while taking up project from here on.
