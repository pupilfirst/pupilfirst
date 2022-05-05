ruby '2.7.6'

source 'https://rubygems.org'

# Ruby on Rails. http://rubyonrails.org
gem 'rails', '~> 6.1.5'

gem 'dotenv-rails', '~> 2.7.6', groups: %i[development test]

gem 'attribute_normalizer', '~> 1.2.0.b' # Attribute normalization. TODO: Check to see if version lock can be removed.
gem 'active_storage_validations', '~> 0.9' # Better validations for active_storage.
gem 'fastimage', '~> 2.2'
gem 'image_processing', '~> 1.12' # Gem to support variants in ActiveStorage

# Use Webpack to manage app-like JavaScript modules in Rails.
gem 'webpacker', '~> 5.4'
gem 'devise', '~> 4.7', '>= 4.7.1' # User auth library.
gem 'jbuilder', '~> 2.11' # Standard part of Rails, but unused, since we don't have an API.
gem 'pg', '~> 1.2' # PostgreSQL support.
gem 'pg_search', '~> 2.3' # builds ActiveRecord named scopes that take advantage of PostgreSQL's full text search.
gem 'activerecord-precounter', '~> 0.4' # N+1 count query optimizer for ActiveRecord.
gem 'turbolinks', '~> 5.2' # Quicker page navigation. https://github.com/turbolinks/turbolinks
gem 'rest-client', '~> 2.1' # Used to contact Fast Alerts' API.
gem 'valid_url', '= 0.0.4', github: 'ralovets/valid_url' # URL validation: https://github.com/ralovets/valid_url
gem 'puma', '< 6' # The Puma ruby web server.
gem 'slowpoke', '~> 0.3' # Rack::Timeout enhancements for Rails. https://github.com/ankane/slowpoke
gem 'delayed_job_active_record', '~> 4.1' # Delayed Job for deferring tasks.
gem 'delayed-web', '~> 0.4' # A rails engine that provides a simple web interface for exposing the Delayed::Job queue.
gem 'seedbank', '~> 0.5' # Better organized seed data.
gem 'font-awesome-rails', '~> 4.7' # Icons from font-awesome!
gem 'kramdown', '~> 2.3' # kramdown is a fast, pure Ruby Markdown superset converter, using a strict syntax definition and supporting several common extensions. http://kramdown.gettalong.org
gem 'motion-markdown-it', '~> 8.4.1' # Ruby version of Markdown-it (a CommonMark compliant extensible parser).
gem 'motion-markdown-it-plugins', '~> 8.4.2' # Plugins for motion-markdown-it.
gem 'gaffe', '~> 1.2' # Custom error pages. https://github.com/mirego/gaffe
gem 'acts-as-taggable-on', '~> 8.1' # Tag a single model on several contexts.
gem 'email_inquire', '~> 0.11' # Validate email for format, common typos and one-time email providers
gem 'titleize', '~> 1.4' # better titleizing, modifies Inflector.titleize from default rails
gem 'reform', '~> 2.6' # Form objects decoupled from models. http://www.trailblazer.to/gems/reform
gem 'reform-rails', '~> 0.2'
gem 'virtus', '~> 2.0' # Required for reform coercion. Attributes on Steroids for Plain Old Ruby Objects
gem 'dry-validation', '~> 1.7' # There seems to be a dependency bug in reform's coercion code - it required dry-types.
gem 'postmark-rails', '~> 0.21' # Official integration library for using Rails and ActionMailer with the Postmark HTTP API.
gem 'responders', '~> 3.0' # A set of Rails responders to dry up your application (respond_to / with)
gem 'rollbar', '~> 3.2' # Exception tracking and logging from Ruby to Rollbar https://rollbar.com
gem 'humanize', '~> 2.5' # Convert numbers to english words
gem 'scarf', '~> 0.2' # A Ruby library for generating initial avatars and identicons.
gem 'kaminari', '~> 1.2' # Scope & Engine based, clean, powerful, customizable and sophisticated paginator.
gem 'rack-throttle', '~> 0.7' # API Rate limiting
gem 'webpush', '~> 1.1.0' # Encryption Utilities for Web Push protocol
gem 'activerecord-nulldb-adapter', '~> 0.8' # A database backend that translates database interactions into no-ops.

# Omniauth providers
gem 'omniauth-google-oauth2', '~> 0.6' # Oauth2 strategy for Google
gem 'omniauth-facebook', '~> 8.0' # Facebook OAuth2 Strategy for OmniAuth http://mkdynamic.github.com/omniauth-facebook
gem 'omniauth-github', '~> 1.2' # GitHub strategy for OmniAuth

gem 'file_validators', '~> 3.0' # Adds file validators to ActiveModel.
gem 'pundit', '~> 2.1' # Minimal authorization through OO design and pure Ruby classes.
gem 'rack-cors', '~> 1.1', require: 'rack/cors' # Rack Middleware for handling CORS, required to serve static assets such as fonts
gem 'graphql', '~> 1.12.16' # Ruby implementation of GraphQL http://graphql-ruby.org
gem 'rodf', '~> 1.1' # ODF generation library for Ruby. https://github.com/westonganger/rodf
gem 'i18n-js', '~> 4.0.0.alpha1' # Provide Rails I18n translations on Javascript.
gem 'batch-loader', '~> 2.0' # Generic lazy batching mechanism to avoid N+1 DB queries.
gem 'recaptcha', '~> 5.8' # ReCaptcha helpers for Ruby apps. http://github.com/ambethia/recaptcha

# Feature toggle
gem 'flipper', '~> 0.22'
gem 'flipper-ui', '~> 0.22'
gem 'flipper-active_record', '~> 0.22'

group :development do
  gem 'letter_opener_web', '~> 1.4' # A web interface for browsing Ruby on Rails sent emails.
  gem 'bullet', '~> 6.1' # Detect N+1 queries.
  gem 'web-console', '~> 4.1' # Rails Console on the Browser.
  gem 'listen', '~> 3.7' # The Listen gem listens to file modifications and notifies you about the changes.
  gem 'graphiql-rails', '~> 1.8'
end

group :test do
  gem 'rspec-retry', '~> 0.6' # Retry randomly failing rspec example. https://github.com/NoRedInk/rspec-retry
  gem 'factory_bot_rails', '~> 6.2' # A library for setting up Ruby objects as test data.
  gem 'capybara', '~> 3.35' # For RSpec feature tests.
  gem 'capybara-email', '~> 3.0' # Test ActionMailer and Mailer messages with Capybara
  gem 'webdrivers', '~> 5.0' # Keep your Selenium WebDrivers updated automatically.
  gem 'capybara-screenshot', '~> 1.0' # Save screenshots on failure!
  gem 'rspec-eventually', '~> 0.2.2' # Rspec helper to match eventually
  gem 'diffy', '~> 3.4' # Easy Diffing in Ruby. https://github.com/samg/diffy
end

group :development, :test do
  gem 'faker', '~> 2.19' # A library for generating fake data such as names, addresses, and phone numbers.
  gem 'rspec-rails', '~> 5.0' # RSpec for Rails 5+.
  gem 'coderay', '~> 1.1' # Pretty syntax highlighting on rspec failure snippets.
  gem 'pry-rails', '~> 0.3.9' # Pry debugger.
  gem 'webmock', '~> 3.14' # Mocking web requests.
  gem 'rubocop', '~> 1.21', require: false # Ruby Style Guide.
  gem 'rubocop-rails', '~> 2.12', require: false # A RuboCop extension focused on enforcing Rails best practices and coding conventions.
  gem 'overcommit', '~> 0.58', require: false # A fully configurable and extendable Git hook manager
  gem 'fuubar', '~> 2.5' # The instafailing RSpec progress bar formatter.

  # TODO: Simplecov has to be locked to < 0.18 until an issue with cc-test-reporter is fixed: https://github.com/codeclimate/test-reporter/issues/413
  gem 'simplecov', '< 0.21', require: false # Code coverage for Ruby. https://github.com/colszowka/simplecov
end

group :production do
  gem 'dalli', '~> 2.7.10' # High performance memcached client for Ruby. https://github.com/petergoldstein/dalli
  gem 'skylight', '~> 5.1' # Skylight is a smart profiler for Rails, Sinatra, and other Ruby apps.
  gem 'aws-sdk-s3', '~> 1.103', require: false
  gem 'aws-sdk-cloudfront', '~> 1.56', require: false
  gem 'whenever', '~> 1.0', require: false
end
