puts 'Seeding school_strings'

def agreement_text
  <<~AGREEMENT
    #{Faker::Lorem.paragraph(sentence_count: 30)}

    #{Faker::Markdown.ordered_list}
    #{Faker::Lorem.paragraph(sentence_count: 20)}

    #{Faker::Markdown.unordered_list}
  AGREEMENT
end

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

  school.school_strings.where(key: 'privacy_policy').first_or_create!(value: agreement_text)
  school.school_strings.where(key: 'terms_and_conditions').first_or_create!(value: agreement_text)
end
