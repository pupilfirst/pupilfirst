FROM ruby:2.7.5
WORKDIR /build
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs
COPY package.json .
COPY yarn.lock .
COPY Gemfile .
COPY Gemfile.lock .
COPY .bundle/production.config .bundle/config
RUN gem install bundler -v '2.2.33'
RUN bundle install -j4
COPY app .
COPY bsconfig.json .
COPY graphql_schema.json .
RUN corepack enable
COPY . /build
RUN bundle exec rails assets:precompile

FROM ruby:2.7.5-slim
WORKDIR /app
COPY . /app
COPY --from=0 /build/public/assets public/assets
ENTRYPOINT [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]
