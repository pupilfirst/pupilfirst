class AddUserCommentsToMentorMeeting < ActiveRecord::Migration[4.2]
  def change
    add_column :mentor_meetings, :user_comments, :text
  end
end
