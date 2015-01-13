class AddMentorCommentsToMentorMeeting < ActiveRecord::Migration
  def change
    add_column :mentor_meetings, :mentor_comments, :text
  end
end
