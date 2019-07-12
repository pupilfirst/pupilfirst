puts 'Seeding schools (idempotent)'

school_1 = School.where(name: Faker::Lorem.word.capitalize).first_or_create!

# Attach a logo (on light) for school_1.
unless school_1.logo_on_light_bg.attached?
  school_1.logo_on_light_bg.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'logo_sv_on_light_bg.png')),
    filename: 'logo_sv_on_light_bg.png'
  )
end

# Attach a logo (on dark) for school_1.
unless school_1.logo_on_dark_bg.attached?
  school_1.logo_on_dark_bg.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'logo_sv_on_dark_bg.png')),
    filename: 'logo_sv_on_dark_bg.png'
  )
end

# Attach an icon for school_1.
unless school_1.icon.attached?
  school_1.icon.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'icon_sv.png')),
    filename: 'icon_sv.png'
  )
end

school_2 = School.where(name: Faker::Lorem.word.capitalize).first_or_create!

# Attach a logo for Hackkar.
unless school_2.logo_on_light_bg.attached?
  school_2.logo_on_light_bg.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'logo_hackkar.png')),
    filename: 'logo_hackkar.png'
  )
end
