ruby '2.4.0'

source 'https://rubygems.org'

# Required to suppress warnings about insecure :github source.
git_source(:github) { |repository_path| "https://github.com/#{repository_path}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '= 5.0.2'

gem 'dotenv-rails', groups: [:development, :test]

gem 'inherited_resources', github: 'activeadmin/inherited_resources' # Required for Rails 5 support for activeadmin. TODO: Remove when activeadmin 1.0.0 is released, which is when I'm guessing this gem will be removed.
gem 'activeadmin', github: 'activeadmin/activeadmin' # Tracking master for Rails 5 support. TODO: Revert to rubygems version when 1.0.0 is released.
gem 'flattened_active_admin' # better looking and customizable activeadmin
gem 'attribute_normalizer', '~> 1.2.0.b' # Attribute normalization. TODO: Check to see if version lock can be removed.
gem 'carrierwave' # One uploader to rule them all.
gem 'carrierwave_backgrounder' # Backgrounder for carrierwave.
gem 'carrierwave-bombshelter' # Protects your carrierwave from image bombs (and such).

# Required by Carrierwave to upload to S3.
gem 'fog-aws', require: 'fog/aws'

gem 'coffee-rails', '~> 4.1.0' # Coffeescript on Rails.
gem 'devise' # User auth library.
gem 'devise_invitable' # Allow invites to be sent out.
gem 'jbuilder', '~> 2.0' # Standard part of Rails, but unused, since we don't have an API.
gem 'jquery-rails' # JQuery on Rails.
gem 'mini_magick' # Image processing.
gem 'pg' # PostgreSQL support.
gem 'sass-rails', '~> 5.0'
gem 'slim' # Slim templating.
gem 'turbolinks' # Quicker page navigation. https://github.com/turbolinks/turbolinks
gem 'uglifier', '>= 2.7.2' # JavaScript compressor.
gem 'rest-client' # Used to contact Fast Alerts' API.
gem 'cancancan', '~> 1.8' # Used to manage administrator types and roles in the ActiveAdmin interface.

# Select2 javascript select box improvement library, using in ActiveAdmin interface.
# TODO: This gem currently serves version 3.x of select2. Version 4 (released) has breaking changes. Take care when upgrading.
gem 'select2-rails', '~> 4.0.3'

gem 'bootstrap-sass', '~> 3.3.3' # Official Sass port of Bootstrap.
gem 'autoprefixer-rails' # Autoprefixer for Ruby and Ruby on Rails.
gem 'simple_form', '~> 3.4.0' # Simple-form with support for Bootstrap 3.
gem 'simple_form_fancy_uploads' # simple_form custom inputs to get image/link previews with file uploads. https://github.com/apeacox/simple_form_fancy_uploads
gem 'bootstrap_form', github: 'desheikh/rails-bootstrap-forms', branch: 'master' # TODO: Replace this with v4 branch of bootstrap-ruby/rails-bootstrap-forms See https://trello.com/c/7wUOmaeM

# TODO: The zones list in the gem was outdated.
# Have updated and submitted a PR (https://github.com/ralovets/valid_url/pull/10). Using a personal fork until it's merged.
gem 'valid_url', github: 'ajaleelp/valid_url', branch: 'patch-1' # New url validataion gem
gem 'logstash-logger' # A better logger.
gem 'roadie-rails' # CSS management for e-mails.
gem 'passenger', '>= 5.0.22' # Passenger web-server.
gem 'delayed_job_active_record' # Delayed Job for deferring tasks.
gem 'delayed-web' # A rails engine that provides a simple web interface for exposing the Delayed::Job queue.
gem 'seedbank' # Better organized seed data.
gem 'font-awesome-rails' # Icons from font-awesome!

# Let's not deal with flash messages, yeah? Tracking modified github master with early rendering fix. See link below.
# https://github.com/mobmewireless/unobtrusive_flash/commit/24e7787d16db66f7956747444433a4e47278193a
gem 'unobtrusive_flash', github: 'mobmewireless/unobtrusive_flash', branch: 'master'

gem 'friendly_id' # Slugs for links. http://norman.github.io/friendly_id
gem 'gravtastic' # Use gravatars as fallback avatars
gem 'require_all' # Easier folder require-s.
gem 'lita', github: 'svdotco/lita', require: false # Lita without rack version limitation. TODO: Replace with official version when it drops rack < v2 limitation.
gem 'lita-slack', github: 'litaio/lita-slack', require: false # Lita adapter for Slack. TODO: removing github repo tracking when gem is updated
gem 'kramdown' # kramdown is a fast, pure Ruby Markdown superset converter, using a strict syntax definition and supporting several common extensions. http://kramdown.gettalong.org
gem 'gaffe' # Custom error pages. https://github.com/mirego/gaffe
gem 'google_calendar', github: 'northworld/google_calendar' # Thin wrapper over Google Calendar API.
gem 'recaptcha', require: 'recaptcha/rails' # ReCaptcha helpers for ruby apps http://github.com/ambethia/recaptcha
gem 'groupdate' # The simplest way to group temporal data. https://github.com/ankane/groupdate
gem 'videojs_rails' # Video JS for Rails 3.1+ Asset Pipeline. https://github.com/seanbehan/videojs_rails
gem 'react-rails' # For automatically transforming JSX and using React in Rails.
gem 'has_secure_token' # Used to create tokens for models (eg: for Faculty). TODO: Will be included with ActiveRecord in Rails 5.
gem 'ahoy_matey', '~> 1.3' # Analytics for Rails
gem 'acts-as-taggable-on', '~> 4.0.0' # Tag a single model on several contexts.
gem 'will_paginate-bootstrap4' # This gem integrates the Twitter Bootstrap pagination component with the will_paginate pagination gem.

# TODO: Switch to vendor's version of 'shortener' gem when Rails 5 support has been added.
gem 'shortener', github: 'harigopal/shortener', branch: '74-rails-5-support' # generate short SV.CO urls for files, links etc

gem 'titleize' # better titleizing, modifies Inflector.titleize from default rails
gem 'addressable' # Addressable is a replacement for the URI implementation that is part of Ruby's standard library. https://github.com/sporkmonger/addressable
gem 'reform' # Form objects decoupled from models. http://www.trailblazer.to/gems/reform
gem 'reform-rails'
gem 'virtus' # Required for reform coercion. Attributes on Steroids for Plain Old Ruby Objects
gem 'dry-validation' # There seems to be a dependency bug in reform's coercion code - it required dry-types.
gem 'postmark-rails' # Official integration library for using Rails and ActionMailer with the Postmark HTTP API.
gem 'intercom-rails' # The easiest way to install Intercom in a Rails app.
gem 'intercom', '~> 3.5.1' # Ruby bindings for the Intercom API
gem 'jspdf-rails' # HTML5 client-side pdf generation - for certificates
gem 'draper', '~> 3.0.0.pre1' # Decorators/View-Models for Rails Applications # TODO: Pre-release version for Rails 5 support. Upgrade to stable when available.
gem 'skylight' # Skylight agent for Ruby https://www.skylight.io
gem 'responders' # A set of Rails responders to dry up your application (respond_to / with)
gem 'prawn' # Used to generate dynmaic portions of agreement pdfs
gem 'prawn-table' # Support for drawing tables in prawn pdfs
gem 'combine_pdf' # Used to combine sections of agreement pdfs
gem 'rollbar' # Exception tracking and logging from Ruby to Rollbar https://rollbar.com
gem 'humanize' # Convert numbers to english words
gem 'quilt', github: 'harigopal/quilt' # A Ruby library for generating identicons.
gem 'descriptive_statistics', '~> 2.4.0', require: 'descriptive_statistics/safe' # Used to calculate basic stat measures such as std. deviation (eg: To calculate relative performance of startups)

# Omniauth providers
gem 'omniauth-google-oauth2' # Oauth2 strategy for Google
gem 'omniauth-facebook' # Facebook OAuth2 Strategy for OmniAuth http://mkdynamic.github.com/omniauth-facebook
gem 'omniauth-github' # GitHub strategy for OmniAuth

gem 'koala', '~> 2.2' # Library for Facebook with support for OAuth authentication, the Graph and REST APIs
gem 'pretender' # Log in as another user in Rails
gem 'file_validators' # Adds file validators to ActiveModel.
gem 'diffy' # Easy Diffing in Ruby.

# Rails assets!
source 'https://rails-assets.org' do
  gem 'rails-assets-pnotify' # Superb notifications library. http://sciactive.github.io/pnotify/
  gem 'rails-assets-curioussolutions-datetimepicker' # Responsive datetimepicker for timeline builder form.
  gem 'rails-assets-trix' # rich text editor from basecamp ( used for eg in the description for targets)
  gem 'rails-assets-bootstrap-tabcollapse' # Bootstrap plugin that switches bootstrap tabs component to collapse component for small screens.
  gem 'rails-assets-masonry' # Masonry works by placing elements in optimal position based on available vertical space.
  gem 'rails-assets-jquery-stickit' # A jQuery plugin provides a sticky header, sidebar or else when scrolling.
  gem 'rails-assets-jquery.scrollTo' # Lightweight, cross-browser and highly customizable animated scrolling with jQuery
  gem 'rails-assets-intro.js' # A better way for new feature introduction and step-by-step users guide for your website and project.
  gem 'rails-assets-perfect-scrollbar' # Minimalistic but perfect custom scrollbar plugin
  gem 'rails-assets-slick-carousel' # the last carousel you'll ever need http://kenwheeler.github.io/slick
  gem 'rails-assets-tether' # A positioning engine to make overlays, tooltips and dropdowns better
  gem 'rails-assets-readmore' # A lightweight jQuery plugin for collapsing and expanding long blocks of text with "Read more" and "Close" links.
  gem 'rails-assets-waypoints' # Waypoints is a library that makes it easy to execute a function whenever you scroll to an element.
  gem 'rails-assets-chartkick' # chartkick lib for admissions dashboard charts
  gem 'rails-assets-gemini-scrollbar' # Custom overlay-scrollbars with native scrolling mechanism for web applications
  gem 'rails-assets-datetimepicker' # jQuery Plugin Date and Time Picker
  gem 'rails-assets-moment' # Parse, validate, manipulate, and display dates in javascript. http://momentjs.com
  gem 'rails-assets-jquery', '~> 2.2.4' # TODO: Lock down jquery to v2 because v3 doesn't work well with AA.
end

group :development do
  gem 'letter_opener_web' # A web interface for browsing Ruby on Rails sent emails.
  gem 'bullet' # Detect N+1 queries.
  # gem 'better_errors' # Better error info on the front-end.
  # gem 'binding_of_caller' # For advanced better_errors features - REPL, local/instance variable inspection etc.
  gem 'web-console', '~> 3.3.0' # TODO: Restored until better_errors speeds up again.
  gem 'listen' # The Listen gem listens to file modifications and notifies you about the changes.
  gem 'rack-mini-profiler' # Middleware that displays speed badge for every html page.

  # Go faster, off the Rails - Benchmarks for your whole Rails app
  gem 'derailed_benchmarks'
  gem 'stackprof' # Required by derailed_benchmarks.
  gem 'oink' # Log parser to identify actions which significantly increase VM heap size
end

group :test do
  gem 'factory_girl_rails', '~> 4.0' # A library for setting up Ruby objects as test data.
  gem 'faker' # A library for generating fake data such as names, addresses, and phone numbers.
  gem 'capybara' # For RSpec feature tests.
  gem 'capybara-email' # Test ActionMailer and Mailer messages with Capybara
  gem 'poltergeist' # A PhantomJS driver for Capybara
  gem 'capybara-screenshot' # Save screenshots on failure!
  gem 'database_cleaner' # Database cleaner can handle complex DB cleanup strategies for test (feature vs regular tests).
end

group :development, :test do
  gem 'rspec-rails', '~> 3.5.0' # Duh.
  gem 'coderay' # Pretty syntax highlighting on rspec failure snippets.
  gem 'pry-rails' # Pry debugger.
  gem 'webmock' # Mocking web requests.
  gem 'rubocop', require: false # Ruby Style Guide.
  gem 'bundler-audit', require: false # Audit gems in gemfile.lock for reported vulnerabilities
  gem 'simplecov', require: false # Code coverage for Ruby 1.9+
  gem 'overcommit', require: false # A fully configurable and extendable Git hook manager
  gem 'fuubar' # The instafailing RSpec progress bar formatter.
  gem 'knapsack' # Knapsack splits tests across CI nodes so that tests will run comparable time on each node.
end

group :production do
  gem 'rails_12factor' # Makes running your Rails app easier. Based on the ideas behind 12factor.net.
  gem 'dalli'
end
