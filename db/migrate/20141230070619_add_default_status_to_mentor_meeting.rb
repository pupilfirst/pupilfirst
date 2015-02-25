class AddDefaultStatusToMentorMeeting < ActiveRecord::Migration
  def change
  	change_column_default :mentor_meetings,:status,'requested'
  end
end
