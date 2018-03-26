class AddLevelsToSchool < ActiveRecord::Migration[5.1]
  def up
    startup_school = School.create!(name: "Startup")
    Level.all.update(school: startup_school)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
