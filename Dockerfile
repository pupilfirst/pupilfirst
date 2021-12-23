# This is a multi-stage build with two stages, where the first is used to precompile assets.
FROM ruby:2.7.5
WORKDIR /build

# Begin by installing gems.
COPY Gemfile .
COPY Gemfile.lock .
RUN gem install bundler -v '2.2.33'
RUN bundle config set --local deployment true
RUN bundle config set --local without development test
RUN bundle install -j4

# We need NodeJS for precompiling assets.
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs

# Install JS dependencies using Yarn.
COPY package.json .
COPY yarn.lock .
RUN corepack enable
RUN yarn install

# Copy over remaining files and set up for precompilation.
COPY . /build

ENV RAILS_ENV="production"
ENV DB_ADAPTER="nulldb"
ENV SECRET_KEY_BASE="1fe25dabb16153b60531917dce0f70e385be7e4f2581e62f10d91a94999de04225b3363b95bbc2b5967902d60be5dc85ae7661f13d325dcdc44dce4b7756c55e"

# AWS requires a lot of keys to initialize.
ENV AWS_ACCESS_KEY_ID=access_key_id_from_aws
ENV AWS_SECRET_ACCESS_KEY=secret_access_key_from_aws
ENV AWS_REGION=us-east-1
ENV AWS_BUCKET=bucket_name_from_aws

# Export the locales.json file.
RUN bundle exec i18n export

# Compile ReScript files to JS.
RUN yarn run re:build

# Before precompiling, let's remove bin/yarn to prevent reinstallation of deps via yarn.
RUN rm bin/yarn
RUN bundle exec rails assets:precompile

# With precompilation done, we can move onto the final stage.
FROM ruby:2.7.5-slim

# We'll need the PostgreSQL client in this image.
RUN apt-get update
RUN apt-get -y install postgresql-client

# Let's also upgrade bundler to the same version used in the build.
RUN gem install bundler -v '2.2.33'

WORKDIR /app
COPY . /app

# We'll copy over the precompiled assets, and the vendored gems.
COPY --from=0 /build/public/assets public/assets
COPY --from=0 /build/public/packs public/packs
COPY --from=0 /build/vendor vendor

# Now we can set up bundler again, using the copied over gems.
RUN bundle config set --local deployment true
RUN bundle config set --local without development test
RUN bundle install

ENV RAILS_ENV="production"

RUN mkdir -p tmp/pids
ENTRYPOINT [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]
