source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.2'

# # active_admin_editor from git, since it's latest rubygems release is before an essential patch added on Jun 25.
# gem 'active_admin_editor', git: 'https://github.com/ejholmes/active_admin_editor.git'

# ActiveAdmin doesn't like 4.2 at all (for the moment). Switch this to stable when available.
gem 'activeadmin', github: 'activeadmin'
gem 'inherited_resources'

gem 'attribute_normalizer', '~> 1.2.0.b' # Attribute normalization. TODO: Check to see if version lock can be removed.
gem 'carrierwave' # One uploader to rule them all.
gem 'carrierwave_backgrounder' # Backgrounder for carrierwave.
gem 'fog' # required by carrierwave to upload to S3.
gem 'cocoon' # POSSIBLY-USELESS TODO: Figure out what this thing does, and whether it's in use.
gem 'coffee-rails', '~> 4.1.0'
gem 'devise_invitable'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'mini_magick' # Image processing.
gem 'newrelic_rpm' # Reporter for Newrelic Heroku add-on.
gem 'nokogiri'
gem 'pg'
gem 'rubypress' # Wordpress
gem 'sass-rails', '~> 5.0'
gem 'sendgrid_smtpapi' # Sendgrid handles our e-mails.
gem 'sentry-raven' # Reporter for Sentry Heroku add-on.
gem 'slim'

# gem 'turbolinks' # Disabled, because it is a pain in the ass.

gem 'uglifier'
gem 'rest-client' # Used to contact Fast Alerts' API.
gem 'cancancan', '~> 1.8' # Used to manage administrator types and roles in the ActiveAdmin interface.
gem 'phony_rails' # Phone number validation and normalization.
gem 'select2-rails' # Select2 javascript select box improvement library, using in ActiveAdmin interface.
gem 'bootstrap-sass', '~> 3.3.3' # Official Sass port of Bootstrap.
gem 'autoprefixer-rails' # Autoprefixer for Ruby and Ruby on Rails.
gem 'simple_form', '~> 3.1.0.rc2' # Simple-form RC2 with support for Bootstrap 3. TODO: Update simple_form to stable when available.
gem 'validate_url' # URL validation.
gem 'chartkick' # Pretty charts!
gem 'will_paginate-bootstrap' # Paginated tables with Bootstrap # POSSIBLY-USELESS
gem 'logstash-logger' # A better logger.

gem 'datetimepicker-rails', github: 'zpaulovics/datetimepicker-rails', branch: 'master', submodules: true # POSSIBLY-USELESS
gem 'momentjs-rails', '>= 2.8.1',  :github => 'derekprior/momentjs-rails' # POSSIBLY-USELESS

gem 'roadie-rails' # CSS management for e-mails.
gem 'passenger', '~> 5.0.8' # Passenger web-server.
gem 'delayed_job_active_record' # Delayed Job for deferring tasks.
gem 'seedbank' # Better organized seed data.
gem 'wicked' # Multistep form wizard for incubation
gem 'font-awesome-sass', '~> 4.3.0' # Icons from font-awesome!
gem 'unobtrusive_flash', '>=3' # Let's not deal with flash messages, yeah? https://github.com/leonid-shevtsov/unobtrusive_flash
gem 'friendly_id' # Slugs for links. http://norman.github.io/friendly_id
gem 'flexslider', :git => 'https://github.com/constantm/Flexslider-2-Rails-Gem.git' # Flexslider on homepage.

# Rails assets!
source 'https://rails-assets.org' do
  gem 'rails-assets-pnotify' # Superb notifications library. http://sciactive.github.io/pnotify/
  gem 'rails-assets-bootstrap-multiselect' # http://davidstutz.github.io/bootstrap-multiselect/
end

group :development do
  gem 'letter_opener' # In development, open mails sent in browser.
  gem 'bullet' # Detect N+1 queries.
end

group :test do
  gem 'factory_girl', require: false
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.2.0'
  gem 'dotenv' # Load environment variables from .env file.
  gem 'pry-rails' # Pry debugger.
  gem 'webmock', require: false # Mocking web requests.

  gem 'better_errors' # Better error info on the front-end.
  gem 'binding_of_caller'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'did_you_mean' # Enough of silly spellinng mistakes ruining the day !
  gem 'quiet_assets' # Let's not see asset serving messages in the development log!
end

group :production do
  gem 'rails_12factor'
end

gem 'sdoc', '~> 0.4.0', group: :doc

ruby '2.2.2'
