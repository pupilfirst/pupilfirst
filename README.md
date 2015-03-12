# SVLabs Web + API

## Setup for development

### Install Dependencies
  *  Ruby (version specified in .ruby-version)
  *  imagemagick (apt-get install imagemagick)
  *  postgresql (apt-get install postgresql postgresql-contrib libpq-dev)

### Configure
  *  Setup database.yml for postgresql
  *  copy example.env to .env and set the variables as required

### Bundle
    $ bundle install

### Database setup
    $ bin/rake db:setup

Now start the server with `bin/rails s`

## Testing

To execute all tests manually, run:

    bin/rake spec

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

## API Documentation

API documentation is maintained using Apiary.

http://docs.startupvillage.apiary.io/

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

## Coding style conventions

### General

* Tabbing - 2 spaces.
* One blank line at the end of all files.
* No trailing spaces at the end of any line.
* One blank line between discrete blocks of code.
* No more than one blank line between blocks / segments of code.

### Ruby

* Naming: Underscored variables and methods. CamelCase class names - `some_variable, some_method, SomeClass`

### Javascript

* Naming: CamelCase variables and function - `someVariable, someFunction`

### CSS

* Naming: Dash-separated ID-s and classes - `.some-class, #some-id`
