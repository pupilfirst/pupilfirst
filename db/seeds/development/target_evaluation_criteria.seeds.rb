require_relative 'helper'

after 'development:targets', 'development:evaluation_criteria' do
  puts 'Seeding target_evaluation_criteria (noop)'
end
