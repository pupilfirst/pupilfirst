class AddIndexToCohortsName < ActiveRecord::Migration[7.0]
  def change

    # Identify duplicates and update the names
    duplicates = Cohort.group(:name).having('count(*) > 1').pluck(:name)
    duplicates.each do |name|
      cohorts = Cohort.where(name: name)
      cohorts[1..].each_with_index do |duplicate, index|
        duplicate.update!(name: "#{duplicate.name} (copy #{index})")
      end
    end

    # Add unique index after updating duplicates
    add_index :cohorts, :name, unique: true
  end
end
