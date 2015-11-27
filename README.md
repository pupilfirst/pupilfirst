# SV.CO

## Build status

[![Circle CI](https://circleci.com/gh/svlabs/sv.co.svg?style=svg&circle-token=823bb16f00598ed9373b661212008b5fae4e48e1)](https://circleci.com/gh/svlabs/sv.co)

## Setup for development

### Install Dependencies
  *  Ruby - Use RVM to install version specified in `.ruby-version`
  *  imagemagick - `apt-get install imagemagick`
  *  postgresql - `apt-get install postgresql postgresql-contrib libpq-dev`
  *  (OSX) Xcode, and qt5 - `brew install qt5`, followed by `brew link --force qt5`

### Configure
  *  Setup `database.yml` for postgresql.
  *  copy `example.env` to `.env` and set the variables as required.

### Bundle
    $ bundle install

### Database setup
    $ rake db:setup

Now start the server with `rails s`

## Testing

To execute all tests manually, run:

    $ rspec

## Services

Background jobs are written as Rails ActiveJob-s, and deferred using Delayed::Job in the production environment.

To run any jobs in the development environment, simply run:

    $ rake jobs:workoff

## Deployment

Travis CI takes care of deploying after running tests. Simply push to master branch, and Travis will take care of the
rest.

### Manual deployment.

Set up heroku to have access to sv-co app.

Add heroku remote:

    $ git remote add heroku-production git@heroku.com:sv-co.git

Then, to deploy:

* From `master` branch, `git push heroku-production` will push local master to production (sv.co)

To safely deploy:

    $ rspec && git push heroku-production && heroku run rake db:migrate --app sv-co && heroku restart --app sv-co

## Coding style conventions

Basic coding conventions are defined in the .editorconfig file. Download plugin for your editor of choice. http://editorconfig.org/

### General

* One blank line between discrete blocks of code.
* No more than one blank line between blocks / segments of code.

### Ruby

* Naming: Underscored variables and methods. CamelCase class names - `some_variable, some_method, SomeClass`

### Javascript

* Use Coffeescript wherever possible.
* Naming: CamelCase variables and function - `someVariable, someFunction`

### CSS

* Use SCSS everywhere.
* Naming: Dash-separated ID-s and classes - `.some-class, #some-id`
