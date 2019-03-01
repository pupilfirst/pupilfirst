puts 'Seeding school_strings (idempotent)'

after 'development:schools' do
  sv = School.find_by(name: 'SV.CO')

  sv.school_strings.where(key: 'coaches_index_subheading')
    .first_or_create!(value: "We've assembled some of the best engineers from the industry as coaches to provide 1-on-1 guidance to students.")

  sv.school_strings.where(key: 'library_index_subheading')
    .first_or_create!(value: "This is just a small sample of resources available in the SV.CO Library. Approved teams get access to exclusive content produced by our coaches, including presentations, video and audio clips.")

  sv.school_strings.where(key: 'email_address')
    .first_or_create!(value: 'help@sv.co')

  sv.school_strings.where(key: 'address')
    .first_or_create!(value: "SV.CO, #360, 6th Main Road  \n1<sup>st</sup> Block, Koramangala, Bengaluru &mdash; 560034")

  privacy_policy = File.read(Rails.root.join('privacy_policy.md'))

  sv.school_strings.where(key: 'privacy_policy').first_or_create!(value: privacy_policy)

  terms_of_use = File.read(Rails.root.join('terms_of_use.md'))

  sv.school_strings.where(key: 'terms_of_use').first_or_create!(value: terms_of_use)
end
