class SetCourseIdAndPublicForResources < ActiveRecord::Migration[5.2]
  def up
    public_resources = Resource.where(level_id: nil).where(startup_id: nil)
    public_resources.update_all(public: true)

    # One public resource (id: 307) belongs to the VR course, remaining belongs to the startup course
    Resource.find(307).update!(course_id: 3)
    public_resources.where.not(id: 307).update_all(course_id: 1)

    non_public_resources = Resource.all - public_resources
    non_public_resources.each do |resource|
      resource.startup.present? ? resource.update!(course: resource.startup.course) : resource.update!(course: resource.level.course)
    end

    # Archive old resources assigned to startups

    Resource.where.not(startup_id: nil).update_all(archived: true)
  end

  def down
    Resource.all.update_all(public: false, course_id: nil)
  end
end
