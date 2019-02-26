after 'development:schools' do
  puts 'Seeding domains (idempotent)'

  # Domains for school SV.CO.
  sv = School.find_by(name: 'SV.CO')

  %w[sv.pupilfirst.localhost school.sv.localhost].each do |sv_domain|
    sv.domains.where(
      fqdn: sv_domain,
      primary: sv_domain == 'school.sv.localhost'
    ).first_or_create!
  end

  # Domains for school Hackkar.
  hackkar = School.find_by(name: 'Hackkar')

  %w[hackkar.pupilfirst.localhost hackkar.localhost www.hackkar.localhost].each do |hackkar_domain|
    hackkar.domains.where(
      fqdn: hackkar_domain,
      primary: hackkar_domain == 'www.hackkar.localhost'
    ).first_or_create!
  end

  # Domains for school Demo.
  demo = School.find_by(name: 'Demo')
  demo.domains.create!(fqdn: 'demo.pupilfirst.localhost', primary: true)
end
