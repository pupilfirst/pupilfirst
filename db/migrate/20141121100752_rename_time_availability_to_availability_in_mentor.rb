class RenameTimeAvailabilityToAvailabilityInMentor < ActiveRecord::Migration[4.2]
  def change
    rename_column :mentors, :time_availability, :availability
  end
end
