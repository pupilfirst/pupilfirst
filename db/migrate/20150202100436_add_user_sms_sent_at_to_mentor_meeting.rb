class AddUserSmsSentAtToMentorMeeting < ActiveRecord::Migration
  def change
    add_column :mentor_meetings, :user_sms_sent_at, :datetime
  end
end
