ruby '2.4.1'

source 'https://rubygems.org'

# Required to suppress warnings about insecure :github source.
git_source(:github) { |repository_path| "https://github.com/#{repository_path}.git" }

# Ruby on Rails. http://rubyonrails.org
gem 'rails', '~> 5.1.2'

gem 'dotenv-rails', '~> 2.2', groups: %i[development test]

gem 'activeadmin', '~> 1.0.0' # The administration framework for Ruby on Rails applications. https://activeadmin.info
gem 'flattened_active_admin', '~> 0.0' # better looking and customizable activeadmin
gem 'attribute_normalizer', '~> 1.2.0.b' # Attribute normalization. TODO: Check to see if version lock can be removed.
gem 'carrierwave', '~> 1.1' # One uploader to rule them all.

# TODO: Switch to carrierwave_backgrounder from rubygems when a version (with support for Carrierwave v1) is released.
# TODO: carrierwave_backgrounder is also holding back the version of mime-types in use. Check for updates.
gem 'carrierwave_backgrounder', '= 0.4.2', github: 'lardawge/carrierwave_backgrounder' # Backgrounder for carrierwave.
gem 'carrierwave-bombshelter', '~> 0.2' # Protects your carrierwave from image bombs (and such).

# Required by Carrierwave to upload to S3.
gem 'fog-aws', '~> 1.2', require: 'fog/aws'

gem 'coffee-rails', '~> 4.2.0' # Coffeescript on Rails.
gem 'devise', '~> 4.2' # User auth library.
gem 'devise_invitable', '~> 1.7' # Allow invites to be sent out.
gem 'jbuilder', '~> 2.6' # Standard part of Rails, but unused, since we don't have an API.
gem 'jquery-rails', '~> 4.3' # JQuery on Rails.
gem 'mini_magick', '~> 4.6' # Image processing.
gem 'pg', '~> 0.20' # PostgreSQL support.
gem 'sass-rails', '~> 5.0'
gem 'slim', '~> 3.0' # Slim templating.
gem 'turbolinks', '~> 5.0' # Quicker page navigation. https://github.com/turbolinks/turbolinks
gem 'uglifier', '~> 3.1' # JavaScript compressor.
gem 'rest-client', '~> 2.0' # Used to contact Fast Alerts' API.
gem 'cancancan', '~> 2.0' # Used to manage administrator types and roles in the ActiveAdmin interface.
gem 'select2-rails', '~> 4.0' # Select2 javascript select box improvement library, using in ActiveAdmin interface.
gem 'bootstrap-sass', '~> 3.3' # Official Sass port of Bootstrap.
gem 'autoprefixer-rails', '~> 7.1' # Autoprefixer for Ruby and Ruby on Rails.
gem 'simple_form', '~> 3.4' # Simple-form with support for Bootstrap 3.
gem 'simple_form_fancy_uploads', '~> 0.2' # simple_form custom inputs to get image/link previews with file uploads. https://github.com/apeacox/simple_form_fancy_uploads
gem 'bootstrap_form', '= 2.5.2', github: 'desheikh/rails-bootstrap-forms', branch: 'master' # TODO: Replace this with v4 branch of bootstrap-ruby/rails-bootstrap-forms See https://trello.com/c/7wUOmaeM

# TODO: The zones list in the gem was outdated.
# Have updated and submitted a PR (https://github.com/ralovets/valid_url/pull/10). Using a personal fork until it's merged.
gem 'valid_url', '= 0.0.4', github: 'mahesh-krishnakumar/valid_url', branch: 'patch-1' # New url validataion gem
gem 'roadie-rails', '~> 1.1' # CSS management for e-mails.
gem 'puma', '~> 3.9' # The Puma ruby web server.
gem 'rack-timeout', '~> 0.4' # Abort requests that are taking too long - recommended by Heroku to use with Puma
gem 'delayed_job_active_record', '~> 4.1' # Delayed Job for deferring tasks.
gem 'delayed-web', '~> 0.4' # A rails engine that provides a simple web interface for exposing the Delayed::Job queue.
gem 'seedbank', '~> 0.4' # Better organized seed data.
gem 'font-awesome-rails', '~> 4.7' # Icons from font-awesome!

# Let's not deal with flash messages, yeah? Tracking modified github master with early rendering fix. See link below.
# https://github.com/mobmewireless/unobtrusive_flash/commit/24e7787d16db66f7956747444433a4e47278193a
gem 'unobtrusive_flash', '= 3.1.0', github: 'mobmewireless/unobtrusive_flash', branch: 'master'

gem 'friendly_id', '~> 5.2' # Slugs for links. http://norman.github.io/friendly_id
gem 'require_all', '~> 1.4' # Easier folder require-s.
gem 'lita', '= 5.0.0', github: 'svdotco/lita', require: false # Lita without rack version limitation. TODO: Replace with official version when it drops rack < v2 limitation.
gem 'lita-slack', '= 1.8.0', github: 'litaio/lita-slack', require: false # Lita adapter for Slack. TODO: removing github repo tracking when gem is updated
gem 'kramdown', '~> 1.13' # kramdown is a fast, pure Ruby Markdown superset converter, using a strict syntax definition and supporting several common extensions. http://kramdown.gettalong.org
gem 'gaffe', '~> 1.2' # Custom error pages. https://github.com/mirego/gaffe
gem 'google_calendar', '= 0.6.2', github: 'northworld/google_calendar' # Thin wrapper over Google Calendar API.
gem 'groupdate', '~> 3.2' # The simplest way to group temporal data. https://github.com/ankane/groupdate
gem 'videojs_rails', '~> 4.12' # Video JS for Rails 3.1+ Asset Pipeline. https://github.com/seanbehan/videojs_rails
gem 'react-rails', '~> 2.2' # For automatically transforming JSX and using React in Rails.
gem 'ahoy_matey', '~> 1.5' # Analytics for Rails
gem 'acts-as-taggable-on', '~> 5.0' # Tag a single model on several contexts.
gem 'will_paginate-bootstrap4', '~> 0.1' # This gem integrates the Twitter Bootstrap pagination component with the will_paginate pagination gem.
gem 'sendinblue', '~> 2.4' # This is SendinBlue provided API V2 Ruby GEM
gem 'email_inquire', '~> 0.6' # Validate email for format, common typos and one-time email providers
gem 'titleize', '~> 1.4' # better titleizing, modifies Inflector.titleize from default rails
gem 'addressable', '~> 2.5' # Addressable is a replacement for the URI implementation that is part of Ruby's standard library. https://github.com/sporkmonger/addressable
gem 'reform', '~> 2.2' # Form objects decoupled from models. http://www.trailblazer.to/gems/reform
gem 'reform-rails', '~> 0.1'
gem 'virtus', '~> 1.0' # Required for reform coercion. Attributes on Steroids for Plain Old Ruby Objects
gem 'dry-validation', '~> 0.10' # There seems to be a dependency bug in reform's coercion code - it required dry-types.
gem 'postmark-rails', '~> 0.15' # Official integration library for using Rails and ActionMailer with the Postmark HTTP API.
gem 'intercom-rails', '~> 0.3' # The easiest way to install Intercom in a Rails app.
gem 'intercom', '~> 3.5' # Ruby bindings for the Intercom API
gem 'jspdf-rails', '~> 1.0' # HTML5 client-side pdf generation - for certificates
gem 'draper', '~> 3.0' # Decorators/View-Models for Rails Applications # TODO: Pre-release version for Rails 5 support. Upgrade to stable when available.
gem 'responders', '~> 2.3' # A set of Rails responders to dry up your application (respond_to / with)
gem 'prawn', '~> 2.1' # Used to generate dynmaic portions of agreement pdfs
gem 'prawn-table', '~> 0.2' # Support for drawing tables in prawn pdfs
gem 'combine_pdf', '~> 1.0' # Used to combine sections of agreement pdfs
gem 'rollbar', '~> 2.14' # Exception tracking and logging from Ruby to Rollbar https://rollbar.com
gem 'humanize', '~> 1.3' # Convert numbers to english words
gem 'scarf', '~> 0.2' # A Ruby library for generating initial avatars and identicons.
gem 'descriptive_statistics', '~> 2.5', require: 'descriptive_statistics/safe' # Used to calculate basic stat measures such as std. deviation (eg: To calculate relative performance of startups)

# Omniauth providers
gem 'omniauth-google-oauth2', '~> 0.4' # Oauth2 strategy for Google
gem 'omniauth-facebook', '~> 4.0' # Facebook OAuth2 Strategy for OmniAuth http://mkdynamic.github.com/omniauth-facebook
gem 'omniauth-github', '~> 1.2' # GitHub strategy for OmniAuth

gem 'koala', '~> 2.2' # Library for Facebook with support for OAuth authentication, the Graph and REST APIs
gem 'pretender', '~> 0.2' # Log in as another user in Rails
gem 'file_validators', '~> 2.1' # Adds file validators to ActiveModel.
gem 'diffy', '~> 3.2' # Easy Diffing in Ruby.
gem 'rails_server_timings', '~> 1.0' # Server Timing headers for Rails apps. https://github.com/dpogue/rails_server_timings
gem 'pundit', '~> 1.1' # Minimal authorization through OO design and pure Ruby classes.
gem 'github-linguist', '~> 5.0', require: false # Language Savant. https://github.com/github/linguist
gem 'rack-cors', '~>0.4', require: 'rack/cors' # Rack Middleware for handling CORS, required to serve static assets such as fonts

# Rails assets!
source 'https://rails-assets.org' do
  gem 'rails-assets-pnotify', '~> 3.0' # Superb notifications library. http://sciactive.github.io/pnotify/
  gem 'rails-assets-trix', '~> 0.10' # rich text editor from basecamp ( used for eg in the description for targets)
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
  gem 'rails-assets-Chart-js', '~> 2.5' # Simple yet flexible JavaScript charting for designers & developers.
  gem 'rails-assets-chartkick', '~> 2.2' # Create beautiful charts with one line of JavaScript.
  gem 'rails-assets-gemini-scrollbar', '~> 1.5' # Custom overlay-scrollbars with native scrolling mechanism for web applications
  gem 'rails-assets-datetimepicker', '~> 2.5' # jQuery Plugin Date and Time Picker
  gem 'rails-assets-moment', '~> 2.18' # Parse, validate, manipulate, and display dates in javascript. http://momentjs.com
  gem 'rails-assets-jquery', '~> 2.2' # TODO: Lock down jquery to v2 because v3 doesn't work well with AA.
  gem 'rails-assets-lodash', '~> 4.17' # A modern JavaScript utility library delivering modularity, performance, & extras.
end

group :development do
  gem 'letter_opener_web', '~> 1.3' # A web interface for browsing Ruby on Rails sent emails.
  gem 'bullet', '~> 5.5' # Detect N+1 queries.
  # gem 'better_errors' # Better error info on the front-end.
  # gem 'binding_of_caller' # For advanced better_errors features - REPL, local/instance variable inspection etc.
  gem 'web-console', '~> 3.4' # TODO: Restored until better_errors speeds up again.
  gem 'listen', '>= 3.0.5', '< 3.2' # The Listen gem listens to file modifications and notifies you about the changes.
  gem 'rack-mini-profiler', '~> 0.10' # Middleware that displays speed badge for every html page.

  # Go faster, off the Rails - Benchmarks for your whole Rails app
  gem 'derailed_benchmarks', '~> 1.3'
  gem 'stackprof', '~> 0.2' # Required by derailed_benchmarks.
  gem 'oink', '~> 0.10' # Log parser to identify actions which significantly increase VM heap size
  gem 'chromedriver-helper', '~> 1.1' # Easy installation and use of chromedriver, the Chromium project's selenium webdriver adapter.
  gem 'logchange', '~> 1.0' # An alternative approach to managing a changelog.
  gem 'meta_request', '~> 0.4' # Chrome extension for Rails development. https://github.com/dejan/rails_panel
end

group :test do
  gem 'rspec-retry' # Retry randomly failing rspec example. https://github.com/NoRedInk/rspec-retry
  gem 'factory_girl_rails', '~> 4.8' # A library for setting up Ruby objects as test data.
  gem 'faker', '~> 1.7' # A library for generating fake data such as names, addresses, and phone numbers.
  gem 'capybara', '~> 2.13' # For RSpec feature tests.
  gem 'capybara-email', '~> 2.5' # Test ActionMailer and Mailer messages with Capybara
  gem 'selenium-webdriver', '~> 3.3'
  gem 'capybara-screenshot', '~> 1.0' # Save screenshots on failure!
  gem 'database_cleaner', '~> 1.5' # Database cleaner can handle complex DB cleanup strategies for test (feature vs regular tests).
end

group :development, :test do
  gem 'rspec-rails', '~> 3.5' # Duh.
  gem 'coderay', '~> 1.1' # Pretty syntax highlighting on rspec failure snippets.
  gem 'pry-rails', '~> 0.3.5' # Pry debugger.
  gem 'webmock', '~> 3.0' # Mocking web requests.
  gem 'rubocop', '~> 0.49', require: false # Ruby Style Guide.
  gem 'bundler-audit', '~> 0.5', require: false # Audit gems in gemfile.lock for reported vulnerabilities
  gem 'overcommit', '~> 0.38', require: false # A fully configurable and extendable Git hook manager
  gem 'fuubar', '~> 2.2' # The instafailing RSpec progress bar formatter.
  gem 'knapsack', '~> 1.13' # Knapsack splits tests across CI nodes so that tests will run comparable time on each node.
  gem 'rails_stats', '~> 1.0' # external/replacement version of rake stats
  gem 'codecov', '~> 0.1', require: false
end

group :production do
  gem 'rails_12factor', '~> 0.0' # Makes running your Rails app easier. Based on the ideas behind 12factor.net.
  gem 'dalli', '~> 2.7' # High performance memcached client for Ruby. https://github.com/petergoldstein/dalli
  gem 'scout_apm' # detailed Rails application performance analysis.
  gem 'heroku-deflater', '~> 0.6' # Enable gzip compression on heroku, but don't compress images.
end
