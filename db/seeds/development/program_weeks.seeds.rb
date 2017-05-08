require_relative 'helper'

after 'development:batches' do
  puts 'Seeding program weeks'

  names = ['Bootcamp', 'Select Idea', 'Get Product Clarity', 'Launch "Coming Soon"'].freeze

  batch = Batch.find_by(batch_number: 2)

  names.each_with_index do |name, index|
    ProgramWeek.create!(name: name, number: index + 1, batch: batch)
  end
end
