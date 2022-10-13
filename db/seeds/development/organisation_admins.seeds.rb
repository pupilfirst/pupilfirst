after 'development:organisations', 'development:school_admins' do
  puts 'Seeding organisation_admins'

  School.all.each do |school|
    admin =
      school
        .school_admins
        .joins(:user)
        .where(users: { email: 'admin@example.com' })
        .first

    school.organisations.each do |organisation|
      OrganisationAdmin.where(user: admin, organisation: organisation)
        .first_or_create
    end
  end
end
