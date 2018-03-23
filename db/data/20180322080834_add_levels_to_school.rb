class AddLevelsToSchool < ActiveRecord::Migration[5.1]
  def up
    startup_school = School.create!(name: "Startup School")
    levels = Level.all
    levels.each do |level|
      level.update!(school: startup_school)
    end

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end