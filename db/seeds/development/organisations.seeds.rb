after 'development:schools' do
  puts 'Seeding organisations'

  (1..3).each { |n| Organisation.create!(name: "#{Faker::Company.name} #{n}") }
end
