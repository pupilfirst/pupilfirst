class AddMentorCommentsToMentorMeeting < ActiveRecord::Migration[4.2]
  def change
    add_column :mentor_meetings, :mentor_comments, :text
  end
end
