# Create an admin user for the /admin interface. This user is a 'super-admin', who can do everything possible from the
# ActiveAdmin interface.
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', admin_type: 'superadmin')
