puts 'Seeding admin_users (idempotent)'

# Create an admin user for the /admin interface. This user is a 'super-admin', who can do everything possible from the
# ActiveAdmin interface.
user = User.where(email: 'admin@example.com').first_or_create!

AdminUser.where(user: user).first_or_create!(
  fullname: 'Development Admin',
  email: user.email,
  admin_type: 'superadmin'
)
