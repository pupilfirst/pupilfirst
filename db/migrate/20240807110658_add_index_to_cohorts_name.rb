class AddIndexToCohortsName < ActiveRecord::Migration[7.0]
  def up
    # Identify duplicates and update the names.
    Course.all.find_each do |course|
      duplicates =
        course.cohorts.group(:name).having("count(*) > 1").pluck(:name)

      duplicates.each do |name|
        cohorts = course.cohorts.where(name: name)

        cohorts[1..].each_with_index do |duplicate, index|
          duplicate.update!(name: "#{duplicate.name} (#{index + 1})")
        end
      end
    end

    # Add unique index after updating duplicates.
    add_index :cohorts, %i[name course_id], unique: true
  end

  def down
    remove_index :cohorts, :name
  end
end
