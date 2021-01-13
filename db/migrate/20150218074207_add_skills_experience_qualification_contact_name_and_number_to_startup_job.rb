class AddSkillsExperienceQualificationContactNameAndNumberToStartupJob < ActiveRecord::Migration[4.2]
  def change
    add_column :startup_jobs, :skills, :string
    add_column :startup_jobs, :experience, :string
    add_column :startup_jobs, :qualification, :string
    add_column :startup_jobs, :contact_name, :string
    add_column :startup_jobs, :contact_number, :string
  end
end
