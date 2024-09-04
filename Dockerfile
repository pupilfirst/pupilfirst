# This is a multi-stage build with two stages, where the first is used to precompile assets.
FROM ruby:3.2.2-bookworm AS assets-precompiler
WORKDIR /build

# Begin by installing gems.
COPY Gemfile .
COPY Gemfile.lock .
RUN gem install bundler -v '2.5.7'
RUN bundle config set --local deployment true
RUN bundle config set --local without development test
RUN bundle install -j4

# We need NodeJS & Yarn for precompiling assets.
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN echo 'Package: nodejs\nPin: origin deb.nodesource.com\nPin-Priority: 1001' > /etc/apt/preferences.d/nodesource
RUN apt-get update && apt-get install nodejs -y
RUN corepack enable

# Install JS dependencies using Yarn.
COPY package.json .
COPY yarn.lock .
COPY .yarnrc.docker.yml .yarnrc.yml
COPY .yarn/releases .yarn/releases

# Ignore checksum until issue with react-csv-reader is resolved.
ENV YARN_CHECKSUM_BEHAVIOR=ignore

RUN yarn install

# Copy over remaining files and set up for precompilation.
COPY . /build

# Some basic keys required by Rails.
ENV RAILS_ENV="production"
ENV DB_ADAPTER="nulldb"
ENV SECRET_KEY_BASE="1fe25dabb16153b60531917dce0f70e385be7e4f2581e62f10d91a94999de04225b3363b95bbc2b5967902d60be5dc85ae7661f13d325dcdc44dce4b7756c55e"

# AWS requires a lot of keys to initialize.
ENV AWS_ACCESS_KEY_ID=dummy_access_key
ENV AWS_SECRET_ACCESS_KEY=dummy_secret_access_key
ENV AWS_REGION=us-east-1
ENV AWS_BUCKET=dummy_bucket_name

# Export the locales.json file.
RUN bundle exec i18n export

# Compile ReScript files to JS.
RUN yarn run re:build

# Run Rails' asset  precompilation step.
RUN bundle exec rails assets:precompile

# Use a base image that includes necessary tools for building libvips.
# TODO: Remove this stage when switching to Debian "trixie", which
# includes an updated libvips build.
FROM debian:bookworm AS libvips-builder

# Install necessary packages for building libvips
RUN apt-get update && apt-get install -y \
  git \
  build-essential \
  pkg-config \
  libglib2.0-dev \
  libexpat1-dev \
  libtiff5-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libgsf-1-dev \
  meson \
  ninja-build \
  && rm -rf /var/lib/apt/lists/*

# Clone libvips repository
RUN git clone https://github.com/libvips/libvips.git \
  && cd libvips \
  && git checkout v8.15.3

# Build libvips from source
RUN cd libvips \
  && meson setup build --prefix=/usr --buildtype=release -Dintrospection=disabled \
  && cd build \
  && ninja \
  && ninja test \
  && ninja install

# With precompilation done, we can move onto the final stage.
FROM ruby:3.2.2-slim-bookworm

COPY --from=libvips-builder /usr /usr

# We'll need a few packages in this image.
RUN apt-get update && apt-get install -y \
  ca-certificates \
  cron \
  curl \
  gnupg \
  && rm -rf /var/lib/apt/lists/*

# We'll also need the exact version of PostgreSQL client, matching our server version, so let's get it from official repos.
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list

# Now install the exact version of the client we need.
RUN apt-get update && apt-get install -y postgresql-client-12 \
  && rm -rf /var/lib/apt/lists/*

# Set up Tini.
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Set up Supercronic.
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
  SUPERCRONIC=supercronic-linux-amd64 \
  SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

RUN curl -fsSLO "$SUPERCRONIC_URL" \
  && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
  && chmod +x "$SUPERCRONIC" \
  && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
  && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Use the www-data user to run the application
USER www-data

# Let's also upgrade bundler to the same version used in the build.
RUN gem install bundler -v '2.5.7'

WORKDIR /app
COPY --chown=www-data:www-data . /app

# We'll copy over the precompiled assets, public images, and the vendored gems.
COPY --chown=www-data:www-data --from=assets-precompiler /build/public/assets public/assets
COPY --chown=www-data:www-data --from=assets-precompiler /build/public/vite public/vite
COPY --chown=www-data:www-data --from=assets-precompiler /build/vendor vendor

# Now we can set up bundler again, using the copied over gems.
RUN bundle config set --local deployment true
RUN bundle config set --local without development test
RUN bundle install

ENV RAILS_ENV="production"

RUN mkdir -p tmp/pids

# Use Tini.
ENTRYPOINT ["/tini", "--"]

# Run under tini to ensure proper signal handling.
CMD bin/start
