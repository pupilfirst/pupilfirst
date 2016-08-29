# SV.CO

[ ![Codeship Status for SVdotCO/sv.co](https://codeship.com/projects/badb7400-4c67-0134-4ebf-52026d0c47d6/status?branch=master)](https://codeship.com/projects/170220)

## Setup for development

### Install Dependencies
  *  Ruby - Use RVM to install version specified in `.ruby-version`

#### OSX

  *  imagemagick - `brew install imagemagick`
  *  postgresql - Install postgres from http://postgresapp.com
  *  PhantomJS - `brew install phantomjs`

### Configure

  *  Setup `database.yml` for postgresql.
  *  copy `example.env` to `.env` and set the variables as required.
  *  Remove `SENTRY_DSN` key from `.env`. This disables the sentry-raven gem (useful only in production).

### Bundle
    $ bundle install

### Database setup
    $ rake db:setup

### Use [puma-dev](https://github.com/puma/puma-dev) to run the application.

After installing puma-dev using its instructions:

    mkdir ~/.puma-dev && cd ~/.puma-dev
    ln -s ~/path/to/sv_repository sv

It's useful to have puma-dev's log file in easy reach:

    ln -s ~/Library/Logs/puma-dev.log log/

To restart the server:

    touch tmp/restart.txt

If it crashes, gets stuck, etc., kill everything from the master process down.

    ps -ef | grep puma

## Testing

You _might_ need to create the test database that you've configured with environment variables.

To execute all tests manually, run:

    $ rspec

## Services

Background jobs are written as Rails ActiveJob-s, and deferred using Delayed::Job in the production environment.

To run any jobs in the development environment, simply run:

    $ rake jobs:workoff

## Deployment

[Codeship](https://codeship.com) takes care of deploying after running tests. Simply push to master branch, and the rest is taken care of.

There are two buildpacks:

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
