require_relative 'helper'

puts 'Seeding categories'

# Startup Categories
StartupCategory.create! name: 'Enterprise'
StartupCategory.create! name: 'Hardware'
StartupCategory.create! name: 'Analytics'
StartupCategory.create! name: 'Automation'
StartupCategory.create! name: 'Commerce'
