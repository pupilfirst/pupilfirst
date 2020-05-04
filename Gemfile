ruby '2.7.1'

source 'https://rubygems.org'

# Ruby on Rails. http://rubyonrails.org
gem 'rails', '~> 6.0.2.2'

gem 'dotenv-rails', '~> 2.2', groups: %i[development test]

gem 'activeadmin', '~> 2.3.1' # The administration framework for Ruby on Rails applications. https://activeadmin.info
gem 'attribute_normalizer', '~> 1.2.0.b' # Attribute normalization. TODO: Check to see if version lock can be removed.
gem 'active_storage_validations', '~> 0.8' # Better validations for active_storage.
gem 'fastimage', '~> 2.1'
gem 'image_processing', '~> 1.2' # Gem to support variants in ActiveStorage

# Use Webpack to manage app-like JavaScript modules in Rails.
gem 'webpacker', '~> 5.0'

gem 'coffee-rails', '~> 5.0.0' # Coffeescript on Rails.
gem 'devise', '~> 4.7', '>= 4.7.1' # User auth library.
gem 'jbuilder', '~> 2.6' # Standard part of Rails, but unused, since we don't have an API.
gem 'jquery-rails', '~> 4.3' # JQuery on Rails.
gem 'pg', '~> 1.0' # PostgreSQL support.
gem 'pg_search', '~> 2.3' # builds ActiveRecord named scopes that take advantage of PostgreSQL's full text search.
gem 'activerecord-precounter', '~> 0.3' # N+1 count query optimizer for ActiveRecord.
gem 'sass-rails', '>= 6'
gem 'slim', '~> 4.0' # Slim templating.
gem 'turbolinks', '~> 5.0' # Quicker page navigation. https://github.com/turbolinks/turbolinks
gem 'uglifier', '~> 4.1' # JavaScript compressor.
gem 'rest-client', '~> 2.0' # Used to contact Fast Alerts' API.
gem 'select2-rails', '~> 4.0' # Select2 javascript select box improvement library, using in ActiveAdmin interface.

gem 'bootstrap', '>= 4.3.1' # Official Sass port of Bootstrap.
gem 'autoprefixer-rails', '~> 9.4' # Autoprefixer for Ruby and Ruby on Rails.
gem 'bootstrap_form', '~> 4.0' # a Rails form builder that makes it super easy to create beautiful-looking forms using Bootstrap 4

# TODO: The zones list in the gem was outdated.
# Have updated and submitted a PR (https://github.com/ralovets/valid_url/pull/10). Using a personal fork until it's merged.
gem 'valid_url', '= 0.0.4', github: 'mahesh-krishnakumar/valid_url', branch: 'patch-1' # New url validataion gem
gem 'roadie-rails', '~> 2.0' # CSS management for e-mails.
gem 'puma', '~> 4.3' # The Puma ruby web server.
gem 'slowpoke', '~> 0.3' # Rack::Timeout enhancements for Rails. https://github.com/ankane/slowpoke
gem 'delayed_job_active_record', '~> 4.1' # Delayed Job for deferring tasks.
gem 'delayed-web', '~> 0.4' # A rails engine that provides a simple web interface for exposing the Delayed::Job queue.
gem 'seedbank', '~> 0.4' # Better organized seed data.
gem 'font-awesome-rails', '~> 4.7' # Icons from font-awesome!
gem 'friendly_id', '~> 5.3.0' # Slugs for links. http://norman.github.io/friendly_id
gem 'lita', '= 5.0.0', github: 'svdotco/lita', require: false # Lita without rack version limitation. TODO: Replace with official version when it drops rack < v2 limitation.
gem 'lita-slack', '= 1.8.0', github: 'litaio/lita-slack', require: false # Lita adapter for Slack. TODO: removing github repo tracking when gem is updated
gem 'kramdown', '~> 2.1' # kramdown is a fast, pure Ruby Markdown superset converter, using a strict syntax definition and supporting several common extensions. http://kramdown.gettalong.org
gem 'motion-markdown-it', '~> 8.4.1' # Ruby version of Markdown-it (a CommonMark compliant extensible parser).
gem 'motion-markdown-it-plugins', '~> 8.4.2' # Plugins for motion-markdown-it.
gem 'gaffe', '~> 1.2' # Custom error pages. https://github.com/mirego/gaffe

gem 'google_calendar', '= 0.6.4', github: 'northworld/google_calendar' # Thin wrapper over Google Calendar API.

# This is a dependency of google_calendar. Lock the version to 0.4.0 to prevent introduction of sqlite3 into production dependencies.
gem 'TimezoneParser', '= 0.4.0'

gem 'videojs_rails', '~> 4.12' # Video JS for Rails 3.1+ Asset Pipeline. https://github.com/seanbehan/videojs_rails
gem 'react-rails', '~> 2.2' # For automatically transforming JSX and using React in Rails.

gem 'ahoy_matey', '~> 2.0' # Analytics for Rails.
gem 'uuidtools', '~>2.1' # Required by ahoy_matey for ActiveRecord stores.

gem 'acts-as-taggable-on', github: 'spark-solutions/acts-as-taggable-on', branch: 'fix/rails-6-and-failing-specs' # Tag a single model on several contexts. TODO: remove tracking branch when gem is updated for Rails 6 issues
gem 'sendinblue', '~> 2.4' # This is SendinBlue provided API V2 Ruby GEM
gem 'email_inquire', '~> 0.6' # Validate email for format, common typos and one-time email providers
gem 'titleize', '~> 1.4' # better titleizing, modifies Inflector.titleize from default rails
gem 'addressable', '~> 2.5' # Addressable is a replacement for the URI implementation that is part of Ruby's standard library. https://github.com/sporkmonger/addressable
gem 'reform', '~> 2.2' # Form objects decoupled from models. http://www.trailblazer.to/gems/reform
gem 'reform-rails', '~> 0.1'
gem 'virtus', '~> 1.0' # Required for reform coercion. Attributes on Steroids for Plain Old Ruby Objects
gem 'dry-validation', '~> 0.10' # There seems to be a dependency bug in reform's coercion code - it required dry-types.
gem 'postmark-rails', '~> 0.19' # Official integration library for using Rails and ActionMailer with the Postmark HTTP API.
# gem 'intercom-rails', '~> 0.4' # The easiest way to install Intercom in a Rails app.
gem 'intercom', '~> 3.5' # Ruby bindings for the Intercom API
gem 'jspdf-rails', '~> 1.0' # HTML5 client-side pdf generation - for certificates
gem 'responders', '~> 3.0' # A set of Rails responders to dry up your application (respond_to / with)
gem 'rollbar', '~> 2.14' # Exception tracking and logging from Ruby to Rollbar https://rollbar.com
gem 'humanize', '~> 2.1' # Convert numbers to english words
gem 'scarf', '~> 0.2' # A Ruby library for generating initial avatars and identicons.
gem 'descriptive_statistics', '~> 2.5', require: 'descriptive_statistics/safe' # Used to calculate basic stat measures such as std. deviation (eg: To calculate relative performance of startups)
gem 'kaminari', '~> 1.0' # Scope & Engine based, clean, powerful, customizable and sophisticated paginator.
gem 'bootstrap4-kaminari-views', '= 1.0.0', github: 'mahesh-krishnakumar/bootstrap4-kaminari-views' # Bootstrap 4 styling for Kaminari gem

# Omniauth providers
gem 'omniauth-google-oauth2', '~> 0.6' # Oauth2 strategy for Google
gem 'omniauth-facebook', '~> 6.0' # Facebook OAuth2 Strategy for OmniAuth http://mkdynamic.github.com/omniauth-facebook
gem 'omniauth-github', '~> 1.2' # GitHub strategy for OmniAuth

gem 'pretender', '~> 0.3.4' # Log in as another user in Rails
gem 'file_validators', '~> 2.1' # Adds file validators to ActiveModel.
gem 'pundit', '~> 2.0' # Minimal authorization through OO design and pure Ruby classes.
gem 'rack-cors', '~> 1.0', require: 'rack/cors' # Rack Middleware for handling CORS, required to serve static assets such as fonts
gem 'jwt', '~> 2.1' # Ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT), used by Zoom API
gem 'chartkick', '~> 3.3' # Create beautiful charts with one line of JavaScript.
gem 'graphql', '~> 1.10' # Ruby implementation of GraphQL http://graphql-ruby.org
gem 'rodf', '~> 1.1' # ODF generation library for Ruby. https://github.com/westonganger/rodf

# Rails assets!
source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap-tabcollapse', '~> 0.2' # Bootstrap plugin that switches bootstrap tabs component to collapse component for small screens.
  gem 'rails-assets-masonry', '~> 4.1' # Masonry works by placing elements in optimal position based on available vertical space.
  gem 'rails-assets-jquery-stickit', '~> 0.2' # A jQuery plugin provides a sticky header, sidebar or else when scrolling.
  gem 'rails-assets-jquery.scrollTo', '~> 2.1' # Lightweight, cross-browser and highly customizable animated scrolling with jQuery
  gem 'rails-assets-intro.js', '~> 2.4' # A better way for new feature introduction and step-by-step users guide for your website and project.
  gem 'rails-assets-perfect-scrollbar', '~> 0.6' # Minimalistic but perfect custom scrollbar plugin
  gem 'rails-assets-slick-carousel', '~> 1.6' # the last carousel you'll ever need http://kenwheeler.github.io/slick
  gem 'rails-assets-tether', '~> 1.4' # A positioning engine to make overlays, tooltips and dropdowns better
  gem 'rails-assets-readmore', '~> 2.2' # A lightweight jQuery plugin for collapsing and expanding long blocks of text with "Read more" and "Close" links.
  gem 'rails-assets-waypoints', '~> 4.0' # Waypoints is a library that makes it easy to execute a function whenever you scroll to an element.
  gem 'rails-assets-gemini-scrollbar', '~> 1.5' # Custom overlay-scrollbars with native scrolling mechanism for web applications
  gem 'rails-assets-datetimepicker', '~> 2.5' # jQuery Plugin Date and Time Picker
  gem 'rails-assets-moment', '~> 2.18' # Parse, validate, manipulate, and display dates in javascript. http://momentjs.com
  gem 'rails-assets-jquery', '~> 3.3' # TODO: Lock down jquery to v2 because v3 doesn't work well with AA.
  gem 'rails-assets-lodash', '~> 4.17' # A modern JavaScript utility library delivering modularity, performance, & extras.
  gem 'rails-assets-typedjs', '~> 2.0' # A JavaScript Typing Animation Library.
  gem 'rails-assets-jquery.counterup', '~> 2.1' # Lightweight jQuery plugin that counts up to a targeted number when the number becomes visible.
  gem 'rails-assets-jquery-sparkline', '= 2.1.3' # Generates sparklines (small inline charts) directly in the browser.
end

group :development do
  gem 'letter_opener_web', '~> 1.3' # A web interface for browsing Ruby on Rails sent emails.
  gem 'bullet', '~> 6.1' # Detect N+1 queries.
  gem 'web-console', '~> 4.0' # Rails Console on the Browser.
  gem 'listen', '>= 3.0.5', '< 3.2' # The Listen gem listens to file modifications and notifies you about the changes.

  # Go faster, off the Rails - Benchmarks for your whole Rails app
  gem 'derailed_benchmarks', '~> 1.3'
  gem 'stackprof', '~> 0.2' # Required by derailed_benchmarks.
  gem 'oink', '~> 0.10' # Log parser to identify actions which significantly increase VM heap size
  gem 'meta_request', '~> 0.4' # Chrome extension for Rails development. https://github.com/dejan/rails_panel
  gem 'graphiql-rails', '~> 1.7'
end

group :test do
  gem 'rspec-retry', '~> 0.5' # Retry randomly failing rspec example. https://github.com/NoRedInk/rspec-retry
  gem 'factory_bot_rails', '~> 5.0' # A library for setting up Ruby objects as test data.
  gem 'capybara', '~> 3.0' # For RSpec feature tests.
  gem 'capybara-email', '~> 3.0' # Test ActionMailer and Mailer messages with Capybara
  gem 'webdrivers', '~> 4.0' # Keep your Selenium WebDrivers updated automatically.
  gem 'capybara-screenshot', '~> 1.0' # Save screenshots on failure!
  gem "cuprite", '~> 0.5', require: false # Headless Chrome driver for Capybara.
  gem 'rspec-eventually', '~> 0.2.2' # Rspec helper to match eventually
  gem 'diffy', '~> 3.3' # Easy Diffing in Ruby. https://github.com/samg/diffy
end

group :development, :test do
  gem 'faker', '~> 2.10' # A library for generating fake data such as names, addresses, and phone numbers.
  gem 'rspec-rails', '~> 4.0' # RSpec for Rails 5+.
  gem 'coderay', '~> 1.1' # Pretty syntax highlighting on rspec failure snippets.
  gem 'pry-rails', '~> 0.3.5' # Pry debugger.
  gem 'webmock', '~> 3.5' # Mocking web requests.
  gem 'rubocop', '~> 0.82', require: false # Ruby Style Guide.
  gem 'rubocop-rails', '~> 2.4', require: false # A RuboCop extension focused on enforcing Rails best practices and coding conventions.
  gem 'bundler-audit', '~> 0.5', require: false # Audit gems in gemfile.lock for reported vulnerabilities
  gem 'overcommit', '~> 0.38', require: false # A fully configurable and extendable Git hook manager
  gem 'fuubar', '~> 2.5' # The instafailing RSpec progress bar formatter.

  # TODO: Simplecov has to be locked to < 0.18 until an issue with cc-test-reporter is fixed: https://github.com/codeclimate/test-reporter/issues/413
  gem 'simplecov', '< 0.18', require: false # Code coverage for Ruby. https://github.com/colszowka/simplecov
end

group :production do
  gem 'dalli', '~> 2.7' # High performance memcached client for Ruby. https://github.com/petergoldstein/dalli
  gem 'skylight', '~> 4.2' # Skylight is a smart profiler for Rails, Sinatra, and other Ruby apps.
  gem 'heroku-deflater', '~> 0.6' # Enable gzip compression on heroku, but don't compress images.
  gem 'aws-sdk-s3', '~> 1.35 ', require: false
end
