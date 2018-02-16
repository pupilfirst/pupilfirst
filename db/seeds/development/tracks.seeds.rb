puts 'Seeding tracks (idempotent)'

Track.where(name: 'Product', sort_index: -1).first_or_create!
Track.where(name: 'Developer').first_or_create!
