class ChangeGradeToInteger < ActiveRecord::Migration[5.2]
  def up
    change_column :timeline_event_grades, :grade, :integer, using: 'grade::integer'
  end

  def down
    change_column :timeline_event_grades, :grade, :string
  end
end
