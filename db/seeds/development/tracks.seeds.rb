puts 'Seeding tracks (idempotent)'

Track.where(name: 'Product').first_or_create!
Track.where(name: 'Developer').first_or_create!
