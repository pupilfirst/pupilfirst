after 'users' do
  puts 'Seeding admin_users (production) (idempotent)'

  user = User.find_by(email: 'admin@example.com')

  # Create an admin user for the /admin interface. This user is a 'super-admin', who can do everything possible from the
  # ActiveAdmin interface.
  AdminUser.where(user: user).first_or_create!(
    fullname: 'Development Admin',
    admin_type: 'superadmin'
  )
end
