class CleanupStartups < ActiveRecord::Migration[6.1]
  def up
    # Clean up unused data from students table.
    remove_column :founders, :startup_id
    remove_column :founders, :resume_file_id
    remove_column :founders, :dashboard_toured

    # Clean up unused data from courses table.
    remove_column :courses, :ends_at

    # Drop unused tables.
    drop_table :faculty_course_enrollments
    drop_table :faculty_startup_enrollments
    drop_table :startups

    # Clean up slack from coaches.
    remove_column :faculty, :slack_username
    remove_column :faculty, :slack_user_id

    # Clean up slack from students.
    remove_column :founders, :slack_username
    remove_column :founders, :slack_user_id

    # Clean up slack from targets.
    remove_column :targets, :slack_reminders_sent_at

    drop_table :public_slack_messages
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
