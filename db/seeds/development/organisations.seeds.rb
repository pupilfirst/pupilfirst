after 'development:schools' do
  puts 'Seeding organisations'

  School.all.each do |school|
    (1..3).each do |n|
      school.organisations.create!(name: "#{Faker::Company.name} #{n}")
    end
  end
end
