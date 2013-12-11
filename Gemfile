source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.1'

gem 'pg'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
gem 'versionist'
gem 'sucker_punch'
gem 'carrierwave'
gem 'carrierwave_backgrounder', git: 'https://github.com/glhewett/carrierwave_backgrounder.git' # https://github.com/lardawge/carrierwave_backgrounder not updated for sucker_punch v1.0 api changes
gem "mini_magick"
gem "fog", "~> 1.3.1" # required by carrierwave to upload to s3
gem 'activeadmin', github: 'gregbell/active_admin' # master for rails 4
gem "just-datetime-picker"
gem 'active_admin_editor'
gem "attribute_normalizer", "~> 1.2.0.b"
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
