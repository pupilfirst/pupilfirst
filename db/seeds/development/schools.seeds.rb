puts 'Seeding schools (idempotent)'

sv = School.where(name: 'SV.CO').first_or_create!

# Attach a logo (on light) for SV.
unless sv.logo_on_light_bg.attached?
  sv.logo_on_light_bg.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'logo_sv_on_light_bg.png')),
    filename: 'logo_sv_on_light_bg.png'
  )
end

# Attach a logo (on dark) for SV.
unless sv.logo_on_dark_bg.attached?
  sv.logo_on_dark_bg.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'logo_sv_on_dark_bg.png')),
    filename: 'logo_sv_on_dark_bg.png'
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
unless hackkar.logo_on_light_bg.attached?
  hackkar.logo_on_light_bg.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'logo_hackkar.png')),
    filename: 'logo_hackkar.png'
  )
end

School.where(name: 'Demo').first_or_create!
