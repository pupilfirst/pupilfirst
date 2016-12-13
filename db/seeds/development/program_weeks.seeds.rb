require_relative 'helper'

after 'development:batches' do
  puts 'Seeding program weeks'

  names = ['Bootcamp', 'Select Idea', 'Get Product Clarity', 'Launch "Coming Soon"'].freeze

  names.each_with_index do |name, index|
    ProgramWeek.create!(name: name, number: index + 1, batch: Batch.find_by(batch_number: 7), icon_name: ProgramWeek.icon_name_options.sample)
  end
end
