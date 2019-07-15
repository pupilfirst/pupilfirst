after 'development:schools' do
  puts 'Seeding domains (idempotent)'

  # Domains for school.
  school_1 = School.first

  %w[school1.pupilfirst.localhost school1.localhost www.school1.localhost].each do |school_1_domain|
    school_1.domains.where(
      fqdn: school_1_domain,
      primary: school_1_domain == 'www.school1.localhost'
    ).first_or_create!
  end

  # Domains for second school.
  school_2 = School.last

  %w[school2.pupilfirst.localhost school2.localhost www.school2.localhost].each do |school_2_domain|
    school_2.domains.where(
      fqdn: school_2_domain,
      primary: school_2_domain == 'www.school2.localhost'
    ).first_or_create!
  end
end
