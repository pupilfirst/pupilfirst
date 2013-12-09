source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.1'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'versionist'

gem 'carrierwave'

gem "rmagick", "~> 2.13.2"

gem "fog", "~> 1.3.1" # required by carrierwave to upload to s3

gem 'carrierwave_backgrounder'

# gem "active_model_serializers", "~> 0.8.0"

gem 'activeadmin', github: 'gregbell/active_admin' # master for rails 4

gem "just-datetime-picker"

group :development do
	gem 'foreman'
	gem 'seed-fu', github: 'mbleigh/seed-fu'
end

group :test do
	gem 'simplecov', require: false
	gem 'rspec', '~> 3.0.0.beta1'
	gem "factory_girl_rails", "~> 4.0"

end

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0.beta'
end

group :production do
	gem 'rails_12factor'
	gem 'unicorn'
end
group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

ruby "2.0.0"
