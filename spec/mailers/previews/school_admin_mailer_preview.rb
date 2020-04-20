# Preview all emails at http://localhost:3000/rails/mailers/school_admin_mailer
class SchoolAdminMailerPreview < ActionMailer::Preview
  def school_admin_added
    school_admin = SchoolAdmin.first
    user = User.new(name: Faker::Name.name)
    user.email = Faker::Internet.email(name: user.name)
    new_school_admin = SchoolAdmin.new(user: user, created_at: Time.zone.now)

    SchoolAdminMailer.school_admin_added(school_admin, new_school_admin)
  end
end
