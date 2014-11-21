class RenameTimeAvailabilityToAvailabilityInMentor < ActiveRecord::Migration
  def change
    rename_column :mentors, :time_availability, :availability
  end
end
