after "schools", "users" do
  puts "Seeding school_admins (production, idempotent)"

  school = School.first

  user = school.users.with_email("admin@example.com").first

  SchoolAdmin.where(user: user).first_or_create!
end
