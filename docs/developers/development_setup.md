---
id: development_setup
title: Development Setup
sidebar_label: Setup
---

These instructions covers three platforms: **macOS** (11.0), **Ubuntu** (20.04), and **Windows 10**
([WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install-win10#update-to-wsl-2), with Ubuntu 20.04). Instructions
for Ubuntu also apply to Windows, except where special instructions are noted.

## Install and configure dependencies

### Install third-party software

#### On macOS

We'll use [Homebrew](https://brew.sh/) to fetch most of the packages on macOS:

- imagemagick - `brew install imagemagick`
- nginx - `brew install nginx`. Start Nginx server after installation.
- postgresql - Install [Postgres.app](http://postgresapp.com) and follow its
  [instructions](https://postgresapp.com/documentation/install.html), **including** the part about setting up
  command-line tools.

**Important**: Make sure that you start Nginx after you install them. Instructions on how to do that will
be printed to the command-line after it's successfully installed.

#### On Ubuntu

The following command should install all required dependencies on Ubuntu. If you're using another _flavour_ of Linux,
adapt the command to work with the package manager available with your distribution.

    sudo apt-get install imagemagick postgresql postgresql-contrib autoconf libtool nginx libpq-dev

### Install Ruby & Node.js

Use [asdf](https://asdf-vm.com/) to install Ruby and Node.js. Simply run `asdf install` from the project directory. It'll read the required versions from the `.tool-versions` file and install them.

### Install Rubygems

Once Ruby is installed, fetch all gems using Bundler:

    bundle install

You may need to install the `bundler` gem if the version of Ruby you have installed comes with a different `bundler`
version. Simply follow the instructions in the error message, if this occurs.

On macOS, if installation of the `pg` gem crashes, asking for `libpq-fe.h`, run the following commands, and then run `bundle install` again:

```bash
# Find the exact path to pg_config.
find /Applications -name pg_config

# Use the path returned by the above command in the following one. Replace X.Y.Z with the same version that failed to install.
gem install pg -v 'X.Y.Z' -- --with-pg-config=/path/to/pg_config
```

### Fetch JS & ReScript dependencies

1. Install Yarn following [offical instructions](https://yarnpkg.com/getting-started/install).
2. From the root of the repository, run the `yarn` command to install all node modules; this will also install ReScript.

## Set credentials for local database

Let's make sure that PostgreSQL server is up and running using the following command:

    # macOS
    brew services start postgresql

    # Ubuntu
    sudo service postgresql start

**Note for WSL users:** You'll need to run the above command each time you restart Windows, and open up Ubuntu for the first time.

If you're setting up Postgres for the first time, we'll now set a password for the `postgres` database username.

Once PostgreSQL server is running, we'll set a password for the default database user. Open the `psql` CLI:

    # macOS
    psql -U postgres

    # Ubuntu
    sudo -u postgres psql

Then, in the PostgreSQL CLI, set a new password and quit.

    # Set a password for this username.
    \password postgres

    # Quit.
    \q

## Configure application environment variables

1. Copy `example.env` to `.env`.

   ```
   cp example.env .env
   ```

2. Update the values of `DB_USERNAME` and `DB_PASSWORD` in the new `.env` file.

   Use the same values from the previous step. The username should be `postgres`, and the password will be whatever value you've set.

3. Set up push notifications by generating and setting VAPID keys to enable push notifications:

   ```ruby
   # In the Rails console
   vapid_key = Webpush.generate_key

   # Save these in your .env file.
   puts "VAPID_PUBLIC_KEY=#{vapid_key.public_key}\nVAPID_PRIVATE_KEY=#{vapid_key.private_key}"
   ```

   Paste the output into `.env`, replacing the existing lines for these two keys.

The `.env` file contains environment variables that are used to configure the application. The file contains documentation explaining where you should source its values from. If you're just starting out, you shouldn't have to change any variables other than the ones listed above.

## Setup Overcommit

[Overcommit](https://github.com/sds/overcommit) adds automatic checks that prevents us from making silly mistakes when
committing changes.

    bundle exec overcommit --install
    bundle exec overcommit --sign

**Note:** You may need to run `asdf reshim` to update paths, if you've just finished running Ruby's `bundle install` command.

## Seed local database

    bundle exec rails db:setup

This will also _seed_ data into the database that will be useful for testing during development.

## Compile ReScript code

If you've used the `yarn` command to install JS dependencies, then ReScript code should already be compiled at this
point. To compile ReScript code again (if you've made changes), you can either do a one-time build, or set up a watcher.

    # One-time recompilation
    yarn run re:build

    # Recompile, and then watch for changes
    yarn run re:watch

## Start the Rails server

    bundle exec rails server

## Run Webpack Dev Server

Start the Webpack Dev Server on another tab or window:

    yarn run wds

You'll want all three of these processes running for best performance when developing.

Visit the school using your browser at `http://localhost:3000`.

You should be able to sign in as `admin@example.com` (use the _Continue as Developer_ option on the sign-in page), to
test access to all interfaces. Test data has been seeded to the development database to make this process easier.

> If you see an error related to the absence of a `locales.json` file, please make sure that your Rails server is running.

## Enabling multitenancy

**Optional:** If you'd like to enable multitenancy in your development environment, a few additional steps are required.

### Add environment variables

1. Turn on the multitenancy mode by additing the following environment variable.

```
MULTITENANCY=on
```

2. Update the SSO domain.

```
SSO_DOMAIN=sso.school.localhost
```

### Set up a reverse-proxy using Nginx

Use Nginx to set up a reverse proxy on a `.localhost` domain to point it to your web application running on port 3000
(the default Rails server port). Use following server configuration as an example:

1. Create a new Nginx server configuration file...

   - `/usr/local/etc/nginx/servers/pupilfirst` (macOS)
   - `/etc/nginx/sites-enabled/pupilfirst` (Linux)

   ...and save the following configuration inside it:

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
   brew services restart nginx

   # Ubuntu
   sudo service nginx restart
   ```

   On Debian/Ubuntu, NGINX comes with a `sites-enabled/default` file which may need to be removed before
   the LMS will begin responding to requests.

3. You _may_ also need to point the local school domain `school.localhost`, and the `www` and `sso` subdomains, to
   `127.0.0.1` in the `/etc/hosts` file (on macOS and Ubuntu), and the `C:\Windows\System32\Drivers\etc\hosts` file on Windows:

   ```
   # Append to the /etc/hosts file.
   127.0.0.1       school.localhost
   127.0.0.1       www.school.localhost
   127.0.0.1       sso.school.localhost
   ```

If your Nginx reverse-proxy has been set up correctly, then visit the school using your browser at
`http://school.localhost`.
