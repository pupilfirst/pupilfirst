# SV.CO

## Setup for development

### Install Dependencies
  *  Ruby - Use RVM to install version specified in `.ruby-version`

#### OSX

  *  imagemagick - `brew install imagemagick`
  *  postgresql - Install postgres from http://postgresapp.com
  *  (OSX) Xcode, and qt5 - `brew install qt5`, followed by `brew link --force qt5`

#### Ubuntu (14.04 CI)

  * `sudo apt-get install build-essential libgmp-dev`
  * PostgreSQL - `sudo apt-get install postgresql postgresql-contrib libpq-dev`
  * Capybara-webkit deps - `sudo apt-get install xvfb gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x`

### Configure
  *  Setup `database.yml` for postgresql.
  *  copy `example.env` to `.env` and set the variables as required.
  *  Remove `SENTRY_DSN` key from `.env`. This disables the sentry-raven gem (useful only in production).

### Bundle
    $ bundle install

### Database setup
    $ rake db:setup

Now start the server with `rails s`

## Testing

You _might_ need to create the test database that you've configured with environment variables.

To execute all tests manually, run:

    $ rspec

## Services

Background jobs are written as Rails ActiveJob-s, and deferred using Delayed::Job in the production environment.

To run any jobs in the development environment, simply run:

    $ rake jobs:workoff

## Deployment

[StriderCD](https://strider.sv.co) takes care of deploying after running tests. Simply push to master branch, and
Strider will take care of the rest.

There are two buildpacks

  1. Heroku's default ruby buildpack: https://github.com/heroku/heroku-buildpack-ruby
  2. Custom rake tasks (for migrations): https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks

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
