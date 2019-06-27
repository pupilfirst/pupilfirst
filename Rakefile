require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

# Update the ruby-advisory-db and run audit
task default: 'bundler:audit'

# Requiring webdrivers tasks manually should not be required in Rails, as per the documentation, but it's necessary as
# of Rails v5.2.3 and Webdrivers v4.0.0.
if Rails.env.development?
  require 'webdrivers'
  load 'webdrivers/Rakefile'
end
