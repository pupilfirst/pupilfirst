![PupilFirst Logo](https://s3.amazonaws.com/public-assets.sv.co/random/201908/pupilfirst-logo-300px.png)
---
![TeamCity Status for SVdotCO/pupilfirst](https://ci.sv.co/app/rest/builds/buildType:(id:PupilFirst_ContinuousIntegration)/statusIcon)
[![codecov](https://codecov.io/gh/SVdotCO/pupilfirst/branch/master/graph/badge.svg?token=WkjxHcrnL4)](https://codecov.io/gh/SVdotCO/pupilfirst)
---
## Setup for development

1. [Install and configure dependencies](#install-dependencies)
    1. [Install Rubygems](#install-rubygems)
    2. [Set credentials for local database](#set-credentials-for-local-database)
    3. [Setup Javascript Environment](#setup-javascript-environment)
    4. [Setup ReasonML environment](#setup-reasonml-environment)
2. [Configure application environment variables](#configure-application-environment-variables)
3. [Setup Overcommit](#setup-overcommit)
4. [Seed local database](#seed-local-database)
5. [Set up a reverse-proxy using Nginx](#set-up-a-reverse-proxy-using-nginx)

### Install Dependencies

#### On OSX

  * Ruby - Use [rbenv](https://github.com/rbenv/rbenv) to install version specified in `.ruby-version`.
  * imagemagick - `brew install imagemagick`
  * postgresql - Install [Postgres.app](http://postgresapp.com) and follow instructions.
  * redis - `brew install redis`
  * nginx - `brew install nginx`

#### On Ubuntu

  * Install Ruby with [rbenv](https://github.com/rbenv/rbenv), as above.
  * Install dependencies:


    sudo apt-get install imagemagick redis-server postgresql postgresql-contrib autoconf libtool nginx

#### Install Rubygems

Once Ruby is installed, fetch all gems using Bundler:

    $ bundle install

If installation of of `pg` gem crashes, asking for `libpq-fe.h`, install the gem with:

**On OSX:**

    find /Applications -name pg_config
    gem install pg -- --with-pg-config=/path/to/pg_config

**On Ubuntu:**

    sudo apt-get install libpq-dev

#### Set credentials for local database

    # Run psql command as postgres user.
    sudo -u postgres psql postgres

    # Set the password for this user.
    \password postgres

    # Quit.
    \q

#### Setup Javascript Environment

1. Install NVM following instructions on the [offical repository.](https://github.com/creationix/nvm)
2. Install Yarn following [offical instructions.](https://yarnpkg.com/en/docs/install)
3. Install all node modules with `yarn` command.

#### Setup ReasonML environment

If you're installed all node modules using _Yarn_, then the basic environment should be ready at this point. However,
you'll also need to install the [Reason CLI toolchain](https://github.com/reasonml/reason-cli) to get all add-on
features to work in VSCode.

`npm install -g reason-cli@latest-macos` (OSX) or `@latest-linux` (Linux)

### Configure application environment variables

Copy `example.env` to `.env`.

    $ cp example.env .env

Now, edit `.env` and set values for database username and password that you used in the previous step.

### Setup Overcommit

[Overcommit](https://github.com/sds/overcommit) adds automatic checks that prevents us from making silly mistakes when
committing changes.

    $ overcommit --install
    $ overcommit --sign

### Seed local database

    $ rails db:setup

This will also seed data useful for development. Once you've started the server, you should be able to sign in as
`admin@example.com` (use the _Continue as Developer_ option in dev env), to test access to all interfaces.

### Set up a reverse-proxy using Nginx

Use Nginx to set up a reverse proxy on a `.localhost` domain to point it to your web application running on port 3000
(the default Rails server port). Use following server configuration as an example:

    server {
      listen 80;
      server_name school1.localhost www.school1.localhost school2.localhost www.school2.localhost sso.pupilfirst.localhost;

      location / {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host $host;
      }
    }

#### OSX

After installing Nginx, place the above configuration in a new file at `/usr/local/etc/nginx/servers/pupilfirst`.

#### Ubuntu

After installing Nginx, place the above configuration in a new file at `/etc/nginx/sites-enabled/pupilfirst`.

## Testing

You _might_ need to create the test database that you've configured with environment variables.

To execute all tests manually, run:

    $ rspec

### Generating coverage report

To generate spec coverage report, run:

    COVERAGE=true rspec

This will generate a __simplecov__ HTML coverage report within `/coverage`

## Services

Background jobs are written as Rails ActiveJob-s, and deferred using
[delayed_job](https://github.com/collectiveidea/delayed_job) in the production environment.

By default, the development and test environment run jobs in-line with a request. If you've manually configured the
application to defer them instead, you can execute the jobs with:

    $ rake jobs:workoff
