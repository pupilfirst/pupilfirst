class AddDefaultStatusToMentorMeeting < ActiveRecord::Migration[4.2]
  def change
  	change_column_default :mentor_meetings,:status,'requested'
  end
end
