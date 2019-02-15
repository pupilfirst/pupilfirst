puts 'Seeding school_strings (idempotent)'

after 'development:schools' do
  sv = School.find_by(name: 'SV.CO')

  sv.school_strings.where(key: 'coaches_index_subheading')
    .first_or_create!(value: "We've assembled some of the best engineers from the industry as coaches to provide 1-on-1 guidance to students.")

  sv.school_strings.where(key: 'library_index_subheading')
    .first_or_create!(value: "This is just a small sample of resources available in the SV.CO Library. Approved teams get access to exclusive content produced by our coaches, including presentations, video and audio clips.")
end
