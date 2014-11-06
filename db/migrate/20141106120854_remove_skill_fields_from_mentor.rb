class RemoveSkillFieldsFromMentor < ActiveRecord::Migration
  def up
    remove_column :mentors, :first_skill
    remove_column :mentors, :first_skill_expertise
    remove_column :mentors, :second_skill
    remove_column :mentors, :second_skill_expertise
    remove_column :mentors, :third_skill
    remove_column :mentors, :third_skill_expertise
  end

  def down
    add_column :mentors, :first_skill, :string
    add_column :mentors, :first_skill_expertise, :string
    add_column :mentors, :second_skill, :string
    add_column :mentors, :second_skill_expertise, :string
    add_column :mentors, :third_skill, :string
    add_column :mentors, :third_skill_expertise, :string
  end
end
