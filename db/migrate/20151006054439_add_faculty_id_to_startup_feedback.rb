class AddFacultyIdToStartupFeedback < ActiveRecord::Migration[4.2]
  def change
    add_reference :startup_feedback, :faculty, index: true, foreign_key: true
  end
end
