class AddLevelUnlockConfigColumns < ActiveRecord::Migration[6.0]
  class Course < ApplicationRecord
  end

  def change
    add_column :courses, :progression_behavior, :string
    add_column :courses, :progression_limit, :integer

    Course.reset_column_information
    Course.update_all(progression_behavior: 'Limited', progression_limit: 1)

    change_column_null :courses, :progression_behavior, false
  end
end
