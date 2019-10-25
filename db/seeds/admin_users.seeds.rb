after 'users' do
  puts 'Seeding admin_users (production, idempotent)'

  # Create an admin user for the /admin interface. This user is a 'super-admin', who can do everything possible from the
  # ActiveAdmin interface.
  AdminUser.where(email: 'admin@example.com').first_or_create!(fullname: 'Development Admin')
end
