puts 'Seeding users (idempotent)'

User.where(email: 'admin@example.com').first_or_create!
