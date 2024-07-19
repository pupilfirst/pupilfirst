ruby "3.2.2"

source "https://rubygems.org"

# Ruby on Rails. http://rubyonrails.org
gem "rails", "~> 7.1.3"

gem "dotenv-rails", "~> 2.8", groups: %i[development test]

gem "attribute_normalizer", "~> 1.2.0.b" # Attribute normalization. TODO: Check to see if version lock can be removed.
gem "active_storage_validations", "~> 1.0" # Better validations for active_storage.
gem "fastimage", "~> 2.2"
gem "image_processing", "~> 1.12" # Gem to support variants in ActiveStorage

gem "vite_rails", "~> 3.0" # Use Vite in Rails and bring joy to your JavaScript experience.
gem "sprockets-rails", "~> 3.4" # Provides Sprockets implementation for Rails 4.x (and beyond) Asset Pipeline
gem "devise", "~> 4.9", ">= 4.9.2" # User auth library.
gem "jbuilder", "~> 2.11" # Standard part of Rails, but unused, since we don't have an API.
gem "pg", "~> 1.2" # PostgreSQL support.
gem "pg_search", "~> 2.3" # builds ActiveRecord named scopes that take advantage of PostgreSQL's full text search.
gem "activerecord-precounter", "~> 0.4" # N+1 count query optimizer for ActiveRecord.
gem "turbolinks", "~> 5.2" # Quicker page navigation. https://github.com/turbolinks/turbolinks
gem "rest-client", "~> 2.1" # Used to contact Fast Alerts' API.
gem "valid_url", "= 0.0.4", github: "ralovets/valid_url" # URL validation: https://github.com/ralovets/valid_url
gem "puma", "~> 5.6" # Use the Puma web server [https://github.com/puma/puma]
gem "slowpoke", "~> 0.5.0" # Rack::Timeout enhancements for Rails. https://github.com/ankane/slowpoke
gem "delayed_job_active_record", "~> 4.1" # Delayed Job for deferring tasks.
gem "delayed-web", "~> 0.4" # A rails engine that provides a simple web interface for exposing the Delayed::Job queue.
gem "seedbank", "~> 0.5" # Better organized seed data.
gem "font-awesome-rails", "~> 4.7" # Icons from font-awesome!
gem "kramdown", "~> 2.3" # kramdown is a fast, pure Ruby Markdown superset converter, using a strict syntax definition and supporting several common extensions. http://kramdown.gettalong.org
gem "motion-markdown-it", "~> 13.0" # Ruby version of Markdown-it (a CommonMark compliant extensible parser).
gem "motion-markdown-it-plugins", "~> 8.4" # Plugins for motion-markdown-it.
gem "gaffe", "~> 1.2" # Custom error pages. https://github.com/mirego/gaffe
gem "acts-as-taggable-on", "~> 10.0" # Tag a single model on several contexts.
gem "titleize", "~> 1.4" # better titleizing, modifies Inflector.titleize from default rails
gem "reform", "~> 2.6" # Form objects decoupled from models. http://www.trailblazer.to/gems/reform
gem "reform-rails", "~> 0.2"
gem "virtus", "~> 2.0" # Required for reform coercion. Attributes on Steroids for Plain Old Ruby Objects
gem "dry-validation", "~> 1.7" # There seems to be a dependency bug in reform's coercion code - it required dry-types.
gem "postmark-rails", "~> 0.22" # Official integration library for using Rails and ActionMailer with the Postmark HTTP API.
gem "responders", "~> 3.0" # A set of Rails responders to dry up your application (respond_to / with)
gem "rollbar", "~> 3.4" # Exception tracking and logging from Ruby to Rollbar https://rollbar.com
gem "humanize", "~> 3.0" # Convert numbers to english words
gem "scarf", "~> 0.2" # A Ruby library for generating initial avatars and identicons.
gem "kaminari", "~> 1.2" # Scope & Engine based, clean, powerful, customizable and sophisticated paginator.
gem "redis", "~> 5.0" # Redis client for use as cache store for rack-attack
gem "rack-attack", "~> 6.6" # A rack middleware for throttling and blocking abusive requests
gem "web-push", "~> 3.0" # Web Push library for Ruby (RFC8030).
gem "activerecord-nulldb-adapter", "~> 1.0" # A database backend that translates database interactions into no-ops.
gem "discordrb", "~> 3.5" # A Ruby wrapper for the Discord API.
gem "groupdate", "~> 6.1" # Group ActiveRecord results by day, week, month, quarter, year, or hour.
gem "discorb", "~> 0.20.0" # A Ruby wrapper for the Discord Bot.
gem "octokit", "~> 8.0" # A Ruby toolkit for the GitHub API.

# OmniAuth providers
gem "omniauth-google-oauth2", "~> 1.1" # Oauth2 strategy for Google.
gem "omniauth-facebook", "~> 9.0" # Facebook OAuth2 Strategy for OmniAuth.
gem "omniauth-github", "~> 2.0" # GitHub OAuth2 Strategy for OmniAuth.
gem "omniauth-discord", "~> 1.0" # Discord OAuth2 Strategy for OmniAuth.

gem "file_validators", "~> 3.0" # Adds file validators to ActiveModel.
gem "pundit", "~> 2.3" # Minimal authorization through OO design and pure Ruby classes.
gem "rack-cors", "~> 2.0", require: "rack/cors" # Rack Middleware for handling CORS, required to serve static assets such as fonts
gem "graphql", "~> 2.0" # Ruby implementation of GraphQL http://graphql-ruby.org
gem "rodf", "~> 1.1" # ODF generation library for Ruby. https://github.com/westonganger/rodf
gem "i18n-js", "~> 4.0" # Export Rails I18n translations for the frontend.
gem "batch-loader", "~> 2.0" # Generic lazy batching mechanism to avoid N+1 DB queries.
gem "recaptcha", "~> 5.14" # ReCaptcha helpers for Ruby apps. http://github.com/ambethia/recaptcha

# Feature toggle
gem "flipper", "~> 1.0"
gem "flipper-ui", "~> 1.0"
gem "flipper-active_record", "~> 1.0"

gem "config", "~> 5.5"

group :development do
  gem "letter_opener_web", "~> 3.0" # A web interface for browsing Ruby on Rails sent emails.
  gem "bullet", "~> 7.0" # Detect N+1 queries.
  gem "web-console", "~> 4.1" # Rails Console on the Browser.
  gem "listen", "~> 3.7" # The Listen gem listens to file modifications and notifies you about the changes.
  gem "graphiql-rails", "~> 1.8"
  gem "htmlbeautifier", "~> 1.4" # A normaliser/beautifier for HTML that also understands embedded Ruby.

  # Requirements for @prettier/plugin-ruby - use latest
  gem "prettier_print"
  gem "syntax_tree"
  gem "syntax_tree-haml"
  gem "syntax_tree-rbs"
end

group :test do
  gem "rspec-retry", "~> 0.6" # Retry randomly failing rspec example. https://github.com/NoRedInk/rspec-retry
  gem "factory_bot_rails", "~> 6.2" # A library for setting up Ruby objects as test data.
  gem "capybara", "~> 3.39" # For RSpec feature tests.
  gem "capybara-email", "~> 3.0" # Test ActionMailer and Mailer messages with Capybara
  gem "selenium-webdriver", "~> 4.11" # Ruby bindings for Selenium
  gem "capybara-screenshot", "~> 1.0" # Save screenshots on failure!
  gem "capybara-shadowdom", "~> 0.3.0"
  gem "rspec-eventually", "~> 0.2.2" # Rspec helper to match eventually
  gem "diffy", "~> 3.4" # Easy Diffing in Ruby. https://github.com/samg/diffy
end

group :development, :test do
  gem "faker", "~> 3.2" # A library for generating fake data such as names, addresses, and phone numbers.
  gem "rspec-rails", "~> 6.0" # RSpec for Rails 5+.
  gem "coderay", "~> 1.1" # Pretty syntax highlighting on rspec failure snippets.
  gem "debug", "~> 1.8" # Debugging functionality for Ruby
  gem "webmock", "~> 3.14" # Mocking web requests.
  gem "rubocop", "~> 1.54", require: false # Ruby Style Guide.
  gem "rubocop-rails", "~> 2.20", require: false # A RuboCop extension focused on enforcing Rails best practices and coding conventions.
  gem "rubocop-performance", "~> 1.21", require: false # A collection of RuboCop cops to check for performance optimizations in Ruby code.
  gem "overcommit", "~> 0.58", require: false # A fully configurable and extendable Git hook manager
  gem "fuubar", "~> 2.5" # The instafailing RSpec progress bar formatter.
  gem "simplecov", "~> 0.21", require: false # Code coverage for Ruby. https://github.com/colszowka/simplecov
end

group :production do
  gem "newrelic_rpm", "~> 9.3" # Performance monitoring
  gem "aws-sdk-s3", "~> 1.103", require: false
  gem "aws-sdk-cloudfront", "~> 1.56", require: false
  gem "cloudflare-rails", "~> 5.0" # Fix request.ip and request.remote_ip in Rails when using Cloudflare
end
