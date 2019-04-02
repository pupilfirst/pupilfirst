puts 'Seeding users (idempotent)'

User.where(email: 'admin@example.com').first_or_create!
User.where(email: 'sa@sv.localhost').first_or_create!
