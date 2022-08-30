after 'development:schools' do
  puts 'Seeding school_strings (idempotent)'

  school = School.first

  # Header links
  3.times do |i|
    school
      .school_links
      .where(kind: 'header', title: Faker::Lorem.word.capitalize)
      .first_or_create!(url: Faker::Internet.url, sort_index: i)
  end

  # Footer links
  6.times do |i|
    school
      .school_links
      .where(kind: 'footer', title: Faker::Lorem.word.capitalize)
      .first_or_create!(url: Faker::Internet.url, sort_index: i)
  end

  # Social links
  school
    .school_links
    .where(
      kind: 'social',
      url: 'https://www.facebook.com/svdotco',
      sort_index: 1
    )
    .first_or_create!
  school
    .school_links
    .where(kind: 'social', url: 'https://twitter.com/svdotco', sort_index: 2)
    .first_or_create!
  school
    .school_links
    .where(
      kind: 'social',
      url: 'https://www.youtube.com/c/svdotco',
      sort_index: 3
    )
    .first_or_create!
  school
    .school_links
    .where(
      kind: 'social',
      url: 'https://www.instagram.com/svdotco',
      sort_index: 4
    )
    .first_or_create!
end
