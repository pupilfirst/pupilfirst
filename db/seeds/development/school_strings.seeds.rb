puts 'Seeding school_strings'

after 'development:schools' do
  school = School.first

  school.school_strings.where(key: 'coaches_index_subheading')
    .first_or_create!(value: Faker::Lorem.sentence)

  school.school_strings.where(key: 'library_index_subheading')
    .first_or_create!(value: Faker::Lorem.sentence)

  school.school_strings.where(key: 'email_address')
    .first_or_create!(value: Faker::Internet.email)

  school.school_strings.where(key: 'address')
    .first_or_create!(value: Faker::Address.full_address)

  school.school_strings.where(key: 'description')
    .first_or_create!(value: Faker::Lorem.sentence)

  privacy_policy = File.read(Rails.root.join('privacy_policy.md'))

  school.school_strings.where(key: 'privacy_policy').first_or_create!(value: privacy_policy)

  terms_of_use = File.read(Rails.root.join('terms_of_use.md'))

  school.school_strings.where(key: 'terms_of_use').first_or_create!(value: terms_of_use)
end
