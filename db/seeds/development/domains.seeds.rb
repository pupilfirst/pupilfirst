after 'development:schools' do
  puts 'Seeding domains (idempotent)'

  sv = School.find_by(name: 'SV.CO')

  sv.domains.where(fqdn: 'sv.localhost').first_or_create!
  sv.domains.where(fqdn: 'www.sv.localhost').first_or_create!
  sv.domains.where(fqdn: 'school.sv.localhost').first_or_create!
end
