puts 'Seeding schools (production, idempotent)'

tags = (1..10).map { Faker::Lorem.words(number: 2).join(' ') }

school = School.where(name: 'Test School').first_or_create!(founder_tag_list: tags)
