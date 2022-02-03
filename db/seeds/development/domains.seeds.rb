after 'development:schools' do
  puts 'Seeding domains (idempotent)'

  # Domains for school.
  school = School.first

  if Rails.application.secrets.multitenancy
    %w[school.localhost www.school.localhost].each do |school_domain|
      school
        .domains
        .where(
          fqdn: school_domain,
          primary: school_domain == 'www.school.localhost'
        )
        .first_or_create!
    end

    # Domains for second school.
    second_school = School.last

    %w[school2.localhost www.school2.localhost].each do |school_2_domain|
      second_school
        .domains
        .where(
          fqdn: school_2_domain,
          primary: school_2_domain == 'www.school2.localhost'
        )
        .first_or_create!
    end
  else
    school.domains.where(fqdn: 'localhost:3000', primary: true).first_or_create!

    school
      .domains
      .where(fqdn: '127.0.0.1:3000', primary: false)
      .first_or_create!
  end
end
