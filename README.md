![PupilFirst Logo](https://public-assets.sv.co/random/201908/pupilfirst-logo-300px.png)
---
[![License: MIT](https://img.shields.io/badge/license-MIT-informational)](https://github.com/SVdotCO/pupilfirst/blob/master/LICENSE)
[![Maintainability](https://api.codeclimate.com/v1/badges/0c7a02f9e0c6c1fb27c8/maintainability)](https://codeclimate.com/github/SVdotCO/pupilfirst/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0c7a02f9e0c6c1fb27c8/test_coverage)](https://codeclimate.com/github/SVdotCO/pupilfirst/test_coverage)
![TeamCity Status for SVdotCO/pupilfirst](https://ci.sv.co/app/rest/builds/buildType:(id:PupilFirst_ContinuousIntegration)/statusIcon.svg)
---

[![Screenshots](https://public-assets.sv.co/random/201909/pupilfirst-screenshots.png)](https://www.pupilfirst.com)

## Changelog

Visit [pupilfirst.com/changelog](https://www.pupilfirst.com/changelog) to view the full changelog.

## Setup for development

1. [Install and configure dependencies](#install-and-configure-dependencies)
    1. [Install third-party software](#install-third-party-software)
    2. [Install Ruby environment](#install-ruby-and-rubygems)
    3. [Setup Javascript environment](#setup-javascript-environment)
    4. [Setup ReasonML environment](#setup-reasonml-environment)
2. [Set credentials for local database](#set-credentials-for-local-database)
3. [Configure application environment variables](#configure-application-environment-variables)
4. [Setup Overcommit](#setup-overcommit)
5. [Seed local database](#seed-local-database)
6. [Set up a reverse-proxy using Nginx](#set-up-a-reverse-proxy-using-nginx)
7. [Compile ReasonML, run Webpack Dev Server, and run the Rails Server](#compile-reasonml-run-webpack-dev-server-and-run-the-rails-server)

### Install and configure dependencies

#### Install third-party software

##### On OSX

We'll use [Homebrew](https://brew.sh/) to fetch most of the packages on OSX:

  * imagemagick - `brew install imagemagick`
  * redis - `brew install redis`
  * nginx - `brew install nginx`
  * postgresql - Install [Postgres.app](http://postgresapp.com) and follow its instructions.

##### On Ubuntu

The following command should install all required dependencies on Ubuntu. If you're using another _flavour_ of Linux,
adapt the command to work with the package manager available with your distribution.

    sudo apt-get install imagemagick redis-server postgresql postgresql-contrib autoconf libtool nginx

#### Install Ruby and Rubygems

Use [rbenv](https://github.com/rbenv/rbenv) to install the version of Ruby specified in the `.ruby-version` file.

Once Ruby is installed, fetch all gems using Bundler:

    $ bundle install

If installation of of `pg` gem crashes, asking for `libpq-fe.h`, install the gem with:

##### On OSX:

    find /Applications -name pg_config
    gem install pg -- --with-pg-config=/path/to/pg_config

##### On Ubuntu:

    sudo apt-get install libpq-dev

#### Setup Javascript Environment

1. Install NVM following instructions on the [offical repository.](https://github.com/creationix/nvm)
2. Install the LTS version of NodeJS: `nvm install --lts`
3. Install Yarn following [offical instructions.](https://yarnpkg.com/en/docs/install). Make sure you do not install
   NodeJS again along with it (read Yarn instructions).
4. Install all node modules with `yarn` command.

#### Setup ReasonML environment

If you've installed all node modules using _Yarn_, then the basic environment should be ready at this point. However,
you'll also need to install the [Reason CLI toolchain](https://github.com/reasonml/reason-cli) to get all add-on
features to work properly in VSCode:

`npm install -g reason-cli@latest-macos` (OSX) or `@latest-linux` (Linux)

### Set credentials for local database

    # Run psql command as postgres user.
    sudo -u postgres psql postgres

    # Set the password for this user.
    \password postgres

    # Quit.
    \q

### Configure application environment variables

Copy `example.env` to `.env`.

    $ cp example.env .env

The file contains documentation explaining where you should source its values from. At minimum, edit `.env` and set
values for Postgres DB username and password that you used in the previous step.

### Setup Overcommit

[Overcommit](https://github.com/sds/overcommit) adds automatic checks that prevents us from making silly mistakes when
committing changes.

    $ overcommit --install
    $ overcommit --sign

### Seed local database

    $ rails db:setup

This will also seed data useful for development. Once you've started the server, you should be able to sign in as
`admin@example.com` (use the _Continue as Developer_ option in dev env), to test access to all interfaces.

#### Optional: Manually mark data migrations as complete

There is an [unacknowledged issue with the data-migrate gem](https://github.com/ilyakatz/data-migrate/issues/82) that
leaves the list of data migrations unpopulated when the database is seeded. If you intend to run data migrations, or are
setting up the platform for production use, you'll need to manually mark all existing data migrations as `up`. To do
this, run the contents of `db/data_schema.rb` in the Rails console - it should look something like this:

```ruby
DataMigrate::Data.define(version: USE_VALUE_FROM_DATA_SCHEMA_FILE)
```

### Set up a reverse-proxy using Nginx

Use Nginx to set up a reverse proxy on a `.localhost` domain to point it to your web application running on port 3000
(the default Rails server port). Use following server configuration as an example:

Place the following configuration at `/usr/local/etc/nginx/servers/pupilfirst` (OSX) or at
`/etc/nginx/sites-enabled/pupilfirst` (Linux).

    server {
      listen 80;
      server_name school.localhost www.school.localhost sso.school.localhost;

      location / {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host $host;
      }
    }

You _may_ also need to point the local school domain `school.localhost`, and the `www` and `sso` subdomains, to
`127.0.0.1` in the `/etc/hosts` file:

    127.0.0.1       school.localhost
    127.0.0.1       www.school.localhost
    127.0.0.1       sso.school.localhost

### Compile ReasonML, run Webpack Dev Server, and run the Rails Server

Compile and watch ReasonML files for changes:

    yarn run bsb -make-world -w

On another tab or window, start the Webpack Dev Server:

    bin/webpack-dev-server

On another tab or window, run the Rails server:

    bundle exec rails server

You'll want all three of these processes running for best performance when developing.

If your Nginx reverse-proxy has been set up correctly, then visit the school using your browser at
`http://www.school.localhost`.

## Testing

You _might_ need to create the test database that you've configured with environment variables.

To execute all tests manually, run:

    $ rspec

### Generating coverage report

To generate spec coverage report, run:

    COVERAGE=true rspec

This will generate coverage report as HTML within the `/coverage` directory.

## Services

Background jobs are written using [Rails ActiveJob](https://guides.rubyonrails.org/active_job_basics.html), and deferred
using [delayed_job](https://github.com/collectiveidea/delayed_job) in the production environment.

By default, the development and test environment run jobs in-line with a request. If you've manually configured the
application to defer them instead, you can execute the jobs with:

    $ rake jobs:workoff
