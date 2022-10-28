after 'development:organisations' do
  puts 'Seeding organisation_admins'

  # Make the first user of each org its org admin.
  Organisation.all.each do |organisation|
    user = organisation.users.first
    organisation.organisation_admins.create!(user: user)
  end
end
