after 'development:schools' do
  puts 'Seeding school_strings (idempotent)'

  school = School.first

  # Header links
  3.times do
    school.school_links.where(kind: 'header', title: Faker::Lorem.word.capitalize).first_or_create!(url: Faker::Internet.url)
  end

  # Footer links
  6.times do
    school.school_links.where(kind: 'footer', title: Faker::Lorem.word.capitalize).first_or_create!(url: Faker::Internet.url)
  end

  # Social links
  school.school_links.where(kind: 'social', url: 'https://www.facebook.com/svdotco').first_or_create!
  school.school_links.where(kind: 'social', url: 'https://twitter.com/svdotco').first_or_create!
  school.school_links.where(kind: 'social', url: 'https://www.youtube.com/c/svdotco').first_or_create!
  school.school_links.where(kind: 'social', url: 'https://www.instagram.com/svdotco').first_or_create!
end
