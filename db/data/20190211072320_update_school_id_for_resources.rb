class UpdateSchoolIdForResources < ActiveRecord::Migration[5.2]
  def up
    Resource.includes(:course).each do |resource|
      resource.update!(school: resource.course.school)
    end
  end

  def down
    Resource.update_all(school_id: nil)
  end
end
