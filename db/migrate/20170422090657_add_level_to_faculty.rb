class AddLevelToFaculty < ActiveRecord::Migration[5.0]
  def change
    add_reference :faculty, :level, foreign_key: true
  end
end
