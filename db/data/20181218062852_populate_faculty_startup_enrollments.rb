class PopulateFacultyStartupEnrollments < ActiveRecord::Migration[5.2]
  def up
    Faculty.includes(:habtm_startups).each do |faculty|
      faculty.habtm_startups.each do |startup|
        FacultyStartupEnrollment.create!(
          safe_to_create: true,
          faculty: faculty,
          startup: startup
        )
      end
    end
  end

  def down
    FacultyStartupEnrollment.delete_all
  end
end
