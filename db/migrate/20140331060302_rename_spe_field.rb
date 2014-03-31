class RenameSpeField < ActiveRecord::Migration
  def self.up
    remove_column :student_entrepreneur_policies, :university_registeration_number
    add_column :student_entrepreneur_policies, :university_registration_number, :string
  end

  def self.down
    remove_column :student_entrepreneur_policies, :university_registration_number
    add_column :student_entrepreneur_policies, :university_registeration_number, :string
  end
end
