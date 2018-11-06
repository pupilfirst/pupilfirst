class AddSchoolToSkills < ActiveRecord::Migration[5.2]
  def change
    add_reference :skills, :school
  end
end
