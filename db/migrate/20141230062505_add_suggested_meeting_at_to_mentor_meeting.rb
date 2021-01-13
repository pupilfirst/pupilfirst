class AddSuggestedMeetingAtToMentorMeeting < ActiveRecord::Migration[4.2]
  def change
    add_column :mentor_meetings, :suggested_meeting_at, :datetime
    remove_column :mentor_meetings, :suggested_meeting_timings, :datetime
  end
end
