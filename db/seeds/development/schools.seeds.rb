puts 'Seeding schools (idempotent)'

School.where(name: 'SV.CO').first_or_create!
