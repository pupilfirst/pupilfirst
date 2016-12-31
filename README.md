# SV.CO

[ ![Codeship Status for SVdotCO/sv.co](https://codeship.com/projects/badb7400-4c67-0134-4ebf-52026d0c47d6/status?branch=master)](https://codeship.com/projects/170220)

## Setup for development

### Install Dependencies

  *  Ruby - Use RVM to install version specified in `.ruby-version`

#### OSX

  *  imagemagick - `brew install imagemagick`
  *  postgresql - `brew cask install postgres`
  *  PhantomJS - `brew install phantomjs`
  *  puma-dev - `brew install puma/puma/puma-dev`

### Configure

  *  Setup `database.yml` for postgresql.
  *  copy `example.env` to `.env` and set the variables as required.
  *  Load environment key for Rollbar from Heroku with:

    heroku config -s --app sv-co | grep ROLLBAR_ACCESS_TOKEN >> .env

### Bundle

    $ bundle install

### Overcommit

    $ overcommit --install
    $ overcommit --sign

### Disable Skylight Dev Warning

    $ skylight disable_dev_warning

### Database setup

    $ rake db:setup

### Use [puma-dev](https://github.com/puma/puma-dev) to run the application.

After installing puma-dev using its instructions:

    cd ~/.puma-dev
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

### Regenerating Knapsack Reports

[Knapsack]() is used to split specs across CI nodes to speed up tests. To update Knapsack's report on all specs, run:

    KNAPSACK_GENERATE_REPORT=true rspec

### Generating coverage report

To generate spec coverage report using _simplecov_, run:

    COVERAGE=true rspec

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
