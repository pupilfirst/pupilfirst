![PupilFirst Logo](https://s3.amazonaws.com/public-assets.sv.co/random/201908/pupilfirst-logo-300px.png)
---
![TeamCity Status for SVdotCO/pupilfirst](https://ci.sv.co/app/rest/builds/buildType:(id:PupilFirst_ContinuousIntegration)/statusIcon)
[![Maintainability](https://api.codeclimate.com/v1/badges/e1b6a2e1d15fba19e49e/maintainability)](https://codeclimate.com/repos/5d638348e7bd3c018b001e28/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/e1b6a2e1d15fba19e49e/test_coverage)](https://codeclimate.com/repos/5d638348e7bd3c018b001e28/test_coverage)
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
6. [Compile ReasonML, run Webpack Dev Server, and run the Rails Server](#compile-reasonml-run-webpack-dev-server-and-run-the-rails-server)

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

##### On OSX:

    find /Applications -name pg_config
    gem install pg -- --with-pg-config=/path/to/pg_config

##### On Ubuntu:

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

If you've installed all node modules using _Yarn_, then the basic environment should be ready at this point. However,
you'll also need to install the [Reason CLI toolchain](https://github.com/reasonml/reason-cli) to get all add-on
features to work properly in VSCode:

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

Place the following configuration at `/usr/local/etc/nginx/servers/pupilfirst` (OSX) or at
`/etc/nginx/sites-enabled/pupilfirst` (Linux).

    server {
      listen 80;
      server_name school1.localhost www.school1.localhost school2.localhost www.school2.localhost sso.pupilfirst.localhost;

      location / {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host $host;
      }
    }

You _may_ also need to point local school domains such as `school1.localhost` and `school2.localhost` domains
(and `www` subdomains) to `127.0.0.1` in the `/etc/hosts` file:

    127.0.0.1       school1.localhost
    127.0.0.1       www.school1.localhost

### Compile ReasonML, run Webpack Dev Server, and run the Rails Server

Compile and watch ReasonML files for changes:

    yarn run bsb -make-world -w

On another tab or window, start the Webpack Dev Server:

    bin/webpack-dev-server

On another tab or window, run the Rails server:

    bundle exec rails server

You'll want all three of these processes running for best performance when developing.

If your Nginx reverse-proxy has been set up correctly, then visit the school using your browser at
`https://www.school1.localhost`.

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
