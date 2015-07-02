source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.2'

# # active_admin_editor from git, since it's latest rubygems release is before an essential patch added on Jun 25.
# gem 'active_admin_editor', git: 'https://github.com/ejholmes/active_admin_editor.git'

# ActiveAdmin doesn't like 4.2 at all (for the moment). Switch this to stable when available.
gem 'activeadmin', github: 'activeadmin'
gem 'inherited_resources'

gem 'acts-as-taggable-on' # POSSIBLY-USELESS
gem 'attribute_normalizer', '~> 1.2.0.b' # POSSIBLY-USELESS
gem 'carrierwave'
gem 'carrierwave_backgrounder'
gem 'cocoon' # POSSIBLY-USELESS
gem 'coffee-rails', '~> 4.1.0'
gem 'devise_invitable'
gem 'fog' # required by carrierwave to upload to s3
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'just-datetime-picker' # POSSIBLY-USELESS
gem 'mini_magick'
gem 'newrelic_rpm' # POSSIBLY-USELESS
gem 'nokogiri'
gem 'omniauth', '~> 1.2.1' # POSSIBLY-USELESS
gem 'pg'
gem 'rubypress' # wordpress # POSSIBLY-USELESS
gem 'sass-rails', '~> 5.0'
gem 'sendgrid_smtpapi'
gem 'sentry-raven'
gem 'slim'
# gem 'turbolinks' # Disabled, because it is a pain in the ass.
gem 'uglifier'
gem 'urbanairship' # POSSIBLY-USELESS
gem 'versionist'
gem 'rest-client'
gem 'cancancan', '~> 1.8' # Used to manage administrator types and roles in the ActiveAdmin interface.
gem 'paper_trail' # Logs changes in critical tables, and displays changelog in ActiveAdmin dashboard. # POSSIBLY-USELESS
gem 'phony_rails' # Phone number validation and normalization.
gem 'select2-rails' # Select2 javascript select box improvement library, using in ActiveAdmin interface.
gem 'nilify_blanks' # Sets database fields to nil if blank values are supplied.
gem 'bootstrap-sass', '~> 3.3.3' # Official Sass port of Bootstrap.
gem 'autoprefixer-rails' # Autoprefixer for Ruby and Ruby on Rails.
gem 'simple_form', '~> 3.1.0.rc2' # Simple-form RC2 with support for Bootstrap 3. TODO: Update simple_form to stable when available.
gem 'validate_url' # URL validation.
gem 'chartkick' # Pretty charts!
gem 'will_paginate-bootstrap' # Paginated tables with Bootstrap # POSSIBLY-USELESS
gem 'logstash-logger' # A better logger.

gem 'datetimepicker-rails', github: 'zpaulovics/datetimepicker-rails', branch: 'master', submodules: true # POSSIBLY-USELESS
gem 'momentjs-rails', '>= 2.8.1',  :github => 'derekprior/momentjs-rails'

gem 'apipie-rails' # Apipie for API documentation!
gem 'maruku' # Let's use Markdown for markup in Apipie.

gem 'roadie-rails' # POSSIBLY-USELESS

gem 'passenger', '~> 5.0.8' # Back to Passenger! Woohoo!

gem 'delayed_job_active_record' # Delayed Job to manage jobs. Let's migrate away from SuckerPunch.
gem 'sucker_punch' # POSSIBLY-USELESS

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
  gem 'letter_opener'
  gem 'guard' # POSSIBLY-USELESS
  gem 'guard-shell' # POSSIBLY-USELESS
  gem 'guard-rspec' # POSSIBLY-USELESS
  # gem "guard-spork"
  gem 'guard-livereload' # POSSIBLY-USELESS
  gem 'childprocess' # POSSIBLY-USELESS
  gem 'terminal-notifier-guard' # POSSIBLY-USELESS
  gem 'bullet' # Detect N+1 queries.
end

group :test do
  gem 'sqlite3' # POSSIBLY-USELESS
  gem 'factory_girl', require: false
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker'
  gem 'json_spec', github: 'collectiveidea/json_spec'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.2.0'
  gem 'rb-inotify', :require => false # POSSIBLY-USELESS
  gem 'rb-fsevent', :require => false # POSSIBLY-USELESS
  gem 'rb-fchange', :require => false # POSSIBLY-USELESS
  gem 'dotenv'
  gem 'pry-rails'
  gem 'webmock', require: false

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug'
  gem 'better_errors'
  gem 'binding_of_caller'


  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Let's try testing Javascript!
  gem 'jasmine-rails' # POSSIBLY-USELESS
  gem 'did_you_mean' # Enough of silly spellinng mistakes ruining the day !

  gem 'quiet_assets' # Let's not see asset serving messages in the development log!
end

group :production do
  gem 'rails_12factor'
  # gem 'pdftk-heroku', git: "https://github.com/gouthamvel/pdftk-heroku.git"
end

gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

ruby '2.2.2'
