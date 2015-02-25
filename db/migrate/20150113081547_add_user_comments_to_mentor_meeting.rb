class AddUserCommentsToMentorMeeting < ActiveRecord::Migration
  def change
    add_column :mentor_meetings, :user_comments, :text
  end
end
