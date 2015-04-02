require_relative 'helper'

after :admin_users do
  admin_user = AdminUser.find_by email: 'admin@example.com'

  # Startups news posted by admin
  News.create!(
    title: 'Example news title',
    remote_picture_url: Faker::Avatar.image,
    author: admin_user
  )
end
