class RemoveUnavailableNextWeekFromFaculty < ActiveRecord::Migration
  def change
    remove_column :faculty, :unavailable_next_week, :boolean
  end
end
