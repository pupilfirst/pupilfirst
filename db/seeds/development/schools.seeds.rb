puts 'Seeding schools (idempotent)'

sv = School.where(name: 'SV.CO').first_or_create!

# Attach a logo for SV.
unless sv.logo.attached?
  sv.logo.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'logo_sv.png')),
    filename: 'logo_sv.png'
  )
end

# Attach an icon for SV.
unless sv.icon.attached?
  sv.icon.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'icon_sv.png')),
    filename: 'icon_sv.png'
  )
end

hackkar = School.where(name: 'Hackkar').first_or_create!

# Attach a logo for Hackkar.
unless hackkar.logo.attached?
  hackkar.logo.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'logo_hackkar.png')),
    filename: 'logo_hackkar.png'
  )
end

School.where(name: 'Demo').first_or_create!
