## ![Pupilfirst Logo](https://public-assets.sv.co/random/201908/pupilfirst-logo-300px.png)

[![License: MIT](https://img.shields.io/badge/license-MIT-informational)](https://github.com/pupilfirst/pupilfirst/blob/master/LICENSE)
[![Maintainability](https://api.codeclimate.com/v1/badges/5a4e81245df6ef5b946b/maintainability)](https://codeclimate.com/github/pupilfirst/pupilfirst/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5a4e81245df6ef5b946b/test_coverage)](https://codeclimate.com/github/pupilfirst/pupilfirst/test_coverage)
[![Continuous Integration](https://github.com/pupilfirst/pupilfirst/workflows/Continuous%20Integration/badge.svg?branch=master)](https://github.com/pupilfirst/pupilfirst/actions?query=workflow%3A%22Continuous+Integration%22)

---

[![Screenshots](https://public-assets.sv.co/random/201909/pupilfirst-screenshots.png)](https://www.pupilfirst.com)

## Changelog

Visit [pupilfirst.com/changelog](https://www.pupilfirst.com/changelog) to view the full changelog.

## Features

Visit [docs.pupilfirst.com](https://docs.pupilfirst.com) for a detailed explanation of Pupilfirst's features.

## Deploying to production

There's an article in the wiki discussing [how to deploy Pupilfirst to Heroku](https://github.com/pupilfirst/pupilfirst/wiki/Deploying-to-Heroku). Even if you're not using Heroku, we highly recommend going through the instructions before getting started.

Have doubts? Talk to our development team on [our Discord server](https://discord.gg/Sh67Tca).

The rest of this README file discusses how to set up this repository for development.

## Setup for development

This documentation covers three platforms: **macOS** (10.15), **Ubuntu** (20.04), and **Windows 10** ([WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install-win10#update-to-wsl-2), with Ubuntu 20.04). Instructions for Ubuntu also apply to Windows, except where special instructions are noted.

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

##### On macOS

We'll use [Homebrew](https://brew.sh/) to fetch most of the packages on macOS:

- imagemagick - `brew install imagemagick`
- redis - `brew install redis`. Start Redis server after installation.
- nginx - `brew install nginx`. Start Nginx server after installation.
- postgresql - Install [Postgres.app](http://postgresapp.com) and follow its
  [instructions](https://postgresapp.com/documentation/install.html), **including** the part about setting up
  command-line tools.

**Important**: Make sure that you start both Nginx and Redis after you install them. Instructions on how to do that will
be printed to the command-line after they're successfully installed.

##### On Ubuntu

The following command should install all required dependencies on Ubuntu. If you're using another _flavour_ of Linux,
adapt the command to work with the package manager available with your distribution.

    $ sudo apt-get install imagemagick redis-server postgresql postgresql-contrib autoconf libtool nginx

#### Install Ruby and Rubygems

Use [rbenv](https://github.com/rbenv/rbenv) to install the version of Ruby specified in the `.ruby-version` file.

Once Ruby is installed, fetch all gems using Bundler:

    $ bundle install

You may need to install the `bundler` gem if the version of Ruby you have installed comes with a different `bundler`
version. Simply follow the instructions in the error message, if this occurs.

If installation of of `pg` gem crashes, asking for `libpq-fe.h`, install the gem with:

##### On macOS:

    # Find the exact path to pg_config.
    $ find /Applications -name pg_config

    # Use the path returned by the above command in the following one. Replace X.Y.Z with the same version that failed to install.
    $ gem install pg -v 'X.Y.Z' -- --with-pg-config=/path/to/pg_config

##### On Ubuntu:

    $ sudo apt-get install libpq-dev

#### Setup ReasonML & Javascript environment

1. Install NVM following instructions on the [offical repository.](https://github.com/creationix/nvm)
2. Install the LTS version of NodeJS: `nvm install --lts`
3. Install Yarn following [offical instructions.](https://yarnpkg.com/en/docs/install).
4. From the root of the repository, run the `yarn` command to install all node modules.

### Set credentials for local database

We'll now set a password for the `postgres` database username.

Make sure that the PostgreSQL server is running. Once that's done, run the following commands:

    # Run psql for the postgres database username.
    $ psql -U postgres

    # Set a password for this username.
    \password postgres

    # Quit.
    \q

Feel free to alter these steps if you're familiar with setting up PostgreSQL.

### Configure application environment variables

1. Copy `example.env` to `.env`.

   ```
   $ cp example.env .env
   ```

2. Update the values of `DB_USERNAME` and `DB_PASSWORD` in the new `.env` file.

   Use the same values from the previous step. The username should be `postgres`, and the password will be whatever
   value you've set.

The `.env` file contains environment variables that are used to configure the application. The file contains
documentation explaining where you should source its values from.

### Setup Overcommit

[Overcommit](https://github.com/sds/overcommit) adds automatic checks that prevents us from making silly mistakes when
committing changes.

    $ overcommit --install
    $ overcommit --sign

### Seed local database

    $ bundle exec rails db:setup

This will also _seed_ data into the database that will be useful for testing during development.

### Set up a reverse-proxy using Nginx

Use Nginx to set up a reverse proxy on a `.localhost` domain to point it to your web application running on port 3000
(the default Rails server port). Use following server configuration as an example:

1. Place the following configuration at `/usr/local/etc/nginx/servers/pupilfirst` (macOS) or at
   `/etc/nginx/sites-enabled/pupilfirst` (Linux).

   ```
   server {
     listen 80;
     server_name school.localhost www.school.localhost sso.school.localhost;

     location / {
       proxy_pass http://localhost:3000/;
       proxy_set_header Host $host;
     }
   }
   ```

2. Restart `nginx` so that it picks up the new configuration.

   ```
   # macOS
   $ brew services restart nginx

   # Ubuntu
   $ sudo systemctl restart nginx
   ```

3. You _may_ also need to point the local school domain `school.localhost`, and the `www` and `sso` subdomains, to
   `127.0.0.1` in the `/etc/hosts` file (on macOS and Ubuntu), and the `C:\Windows\System32\Drivers\etc\hosts` file on Windows:

   ```
   # Append to the /etc/hosts file.
   127.0.0.1       school.localhost
   127.0.0.1       www.school.localhost
   127.0.0.1       sso.school.localhost
   ```

### Compile ReasonML, run Webpack Dev Server, and run the Rails Server

Compile and watch ReasonML files for changes:

    $ yarn run re:watch

Once the compilation is complete, start the Webpack Dev Server on another tab or window:

    $ bin/webpack-dev-server

On a third tab or window, run the Rails server:

    $ bundle exec rails server

You'll want all three of these processes running for best performance when developing.

If your Nginx reverse-proxy has been set up correctly, then visit the school using your browser at
`http://school.localhost`.

## Browse the school with seeded data

You should be able to sign in as `admin@example.com` (use the _Continue as Developer_ option on the sign-in page), to
test access to all interfaces. Test data has been seeded to the development database to make this process easier.

## Automated Testing

The default settings expect Google Chrome to be installed to run specs. To execute all tests, run:

    $ rspec

You can choose which browser the specs run in, using the `JAVASCRIPT_DRIVER` environment variable. Check the
`spec/rails_helper.rb` file for its possible options.

### Generating coverage report

To generate spec coverage report, run:

    $ COVERAGE=true rspec

This will generate coverage report as HTML within the `/coverage` directory.

## Updating GraphQL schema

If you make any changes to the GraphQL schema, you'll need to update the `graphql_schema.json` file by running an
introspection query.

With the Pupilfirst server running, run the `graphql-codegen` script.

    $ yarn run graphql-codegen

It'll visit the local GraphQL end-point which is configured in the `codegen.yml` file, fetch the schema and store it in
the `graphql_schema.json` file.

## Running Background Jobs

Background jobs are written using [Rails ActiveJob](https://guides.rubyonrails.org/active_job_basics.html), and deferred
using [delayed_job](https://github.com/collectiveidea/delayed_job) in the production environment.

By default, the development and test environment run jobs in-line with a request. If you've manually configured the
application to defer them instead, you can execute the jobs with:

    $ rake jobs:workoff

## Editing Documentation

The source of [docs.pupilfirst.com](https://docs.pupilfirst.com) is stored in the `/docs` folder in this repo, and is
managed using [docsify](https://docsify.js.org/).

First, install the docsify CLI globally:

    $ npm i docsify-cli -g

Then serve the `docs` folder on the desired port.

    $ docsify serve docs -p 3010

The `-p` option sets the port. Visit `localhost:PORT` to view docs locally.
