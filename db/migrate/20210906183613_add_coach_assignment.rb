class AddCoachAssignment < ActiveRecord::Migration[6.1]
  def change
    add_column :faculty_course_enrollments,
               :enable_auto_assignment,
               :boolean,
               default: false

    add_reference :timeline_events,
                  :reviewer,
                  foreign_key: {
                    to_table: :faculty
                  }
    add_column :timeline_events, :reviewer_assigned_at, :datetime
  end
end
