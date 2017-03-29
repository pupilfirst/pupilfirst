# SV.CO

[ ![Codeship Status for SVdotCO/sv.co](https://codeship.com/projects/badb7400-4c67-0134-4ebf-52026d0c47d6/status?branch=master)](https://codeship.com/projects/170220)

## Setup for development

### Install Dependencies

#### OSX

  *  Ruby - Use [rbenv](https://github.com/rbenv/rbenv) to install version specified in `.ruby-version`.
  *  imagemagick - `brew install imagemagick`
  *  postgresql - Install [Postgres.app](http://postgresapp.com) and follow instructions.
  *  puma-dev - `brew install puma/puma/puma-dev`

### Configure

  *  Setup `database.yml` for postgresql.
  *  Copy `example.env` to `.env` and set the variables as required.
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

    $ rails db:setup

### Use [puma-dev](https://github.com/puma/puma-dev) to run the application.

After installing puma-dev using its instructions:

    cd ~/.puma-dev
    ln -s ~/path/to/sv_repository sv

It's useful to have puma-dev's log file in easy reach:

    ln -s ~/Library/Logs/puma-dev.log log/

To restart the server:

    touch tmp/restart.txt

If it crashes, gets stuck, etc., kill the master process.

    ps -ef | grep puma
    kill -9 [PUMA_PROCESS_ID]

## Testing

You _might_ need to create the test database that you've configured with environment variables.

To execute all tests manually, run:

    $ rspec

### Regenerating Knapsack Reports

[Knapsack](https://github.com/ArturT/knapsack) is used to split specs across CI nodes to speed up tests. To update Knapsack's report on all specs, run:

    KNAPSACK_GENERATE_REPORT=true rspec

### Generating coverage report

To run specs and push the coverage report to _Coveralls_, ensure ENV contains COVERALLS_REPO_TOKEN and run:

    bundle exec coveralls push

## Services

Background jobs are written as Rails ActiveJob-s, and deferred using Delayed::Job in the production environment.

By default, the development and test environment run jobs in-line. If you've manually configured the application to defer them instead, you can execute the jobs with:

    $ rake jobs:workoff

## Deployment

[Codeship](https://codeship.com) runs specs once commit are pushed to Github. When push is to the `master` branch, and if specs pass, Codeship marks the commit as successful on Github. This prompts Heroku to pick up the commit and deploy a new instance - so the entire process is automated.

We use two buildpacks at Heroku:

  1. Heroku's default ruby buildpack: https://github.com/heroku/heroku-buildpack-ruby
  2. Custom rake tasks (to run DB migrations): https://github.com/gunpowderlabs/buildpack-ruby-rake-deploy-tasks

### Manual deployment.

Set up heroku to have access to sv-co app.

Add heroku remote:

    $ git remote add heroku git@heroku.com:sv-co.git

Then, to deploy:

* From `master` branch, `git push heroku` will push local master to production (sv.co)

To safely deploy:

    $ rspec && git push heroku && heroku run rake db:migrate --app sv-co && heroku restart --app sv-co

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
* Use [BEM](http://getbem.com) for naming classes - `block__element`, or `block__element--modifier`
