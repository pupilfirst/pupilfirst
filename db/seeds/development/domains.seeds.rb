after 'development:schools' do
  puts 'Seeding domains (idempotent)'

  sv = School.find_by(name: 'SV.CO')

  %w[sv.pupilfirst.localhost school.sv.localhost].each do |sv_domain|
    sv.domains.where(fqdn: sv_domain).first_or_create!
  end

  hackkar = School.find_by(name: 'Hackkar')

  %w[hackkar.pupilfirst.localhost hackkar.localhost www.hackkar.localhost].each do |hackkar_domain|
    hackkar.domains.where(fqdn: hackkar_domain).first_or_create!
  end
end
