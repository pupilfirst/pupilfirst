puts 'Seeding schools (production, idempotent)'

School.where(name: 'Test School').first_or_create!
