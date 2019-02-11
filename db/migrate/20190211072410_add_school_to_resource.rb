class AddSchoolToResource < ActiveRecord::Migration[5.2]
  def change
    add_reference :resources, :school
  end
end
