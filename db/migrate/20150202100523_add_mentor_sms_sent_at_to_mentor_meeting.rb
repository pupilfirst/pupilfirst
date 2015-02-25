class AddMentorSmsSentAtToMentorMeeting < ActiveRecord::Migration
  def change
    add_column :mentor_meetings, :mentor_sms_sent_at, :datetime
  end
end
