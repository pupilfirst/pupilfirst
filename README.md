# SVLabs Web + API

## Build status

**Staging:** [![Circle CI](https://circleci.com/gh/SVLabs/api-backend/tree/development.svg?style=svg)](https://circleci.com/gh/SVLabs/api-backend/tree/development)
**Production:** [![Circle CI](https://circleci.com/gh/SVLabs/api-backend/tree/master.svg?style=svg)](https://circleci.com/gh/SVLabs/api-backend/tree/master)

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

or just:

    rspec

## Services

Background jobs are written as Rails ActiveJob-s, and deferred using Delayed::Job in the production environment.

## Deployment

Add heroku remotes:

    $ git remote add heroku-production git@heroku.com:svapp.git
    $ git remote add heroku-staging git@heroku.com:svapp-staging.git

Then, to deploy:

* From `master` branch, `git push heroku-production` will push local master to production (svlabs.in)
* From `development` branch, `git push heroku-staging development:master` will push local development to staging (staging.svlabs.in)

## API Documentation

API documentation is maintained using Apiary.

http://docs.startupvillage.apiary.io/

## Web resources considered for dev
*  http://matthewlehner.net/rails-api-testing-guidelines/
*  https://github.com/joshbuddy/jsonpath
*  http://pivotallabs.com/api-versioning/

## Known Issues
*  n + 1 query optimization need to be added as required.

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
