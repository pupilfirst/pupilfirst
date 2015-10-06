class AddFacultyIdToStartupFeedback < ActiveRecord::Migration
  def change
    add_reference :startup_feedback, :faculty, index: true, foreign_key: true
  end
end
