after 'development:communities' do
  puts 'Seeding topic_categories'

  community = Community.first

  (1..3).each { |n| community.topic_categories.create!(name: "#{Faker::Lorem.word} #{n}") }
end
