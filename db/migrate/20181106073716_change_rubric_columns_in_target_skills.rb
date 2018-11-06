class ChangeRubricColumnsInTargetSkills < ActiveRecord::Migration[5.2]
  def change
    remove_column :target_skills, :rubric_good
    remove_column :target_skills, :rubric_great
    remove_column :target_skills, :rubric_wow
    add_column :target_skills, :rubric, :json
  end
end
