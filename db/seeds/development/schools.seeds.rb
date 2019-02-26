puts 'Seeding schools (idempotent)'

sv = School.where(name: 'SV.CO').first_or_create!

unless sv.logo.attached?
  sv.logo.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'logo_sv.png')),
    filename: 'sv_logo.png'
  )
end

hackkar = School.where(name: 'Hackkar').first_or_create!

unless hackkar.logo.attached?
  hackkar.logo.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'logo_hackkar.png')),
    filename: 'logo_hackkar.png'
  )
end

School.where(name: 'Demo').first_or_create!
