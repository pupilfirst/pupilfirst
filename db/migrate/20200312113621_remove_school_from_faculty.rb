class RemoveSchoolFromFaculty < ActiveRecord::Migration[6.0]
  def change
    remove_reference :faculty, :school
  end
end
