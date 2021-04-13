class CourseTeamsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :level_id
  property :search
  property :tags
  property :sort_by
  property :sort_direction

  def course_teams
    if search.present?
      teams_by_level_and_tag.where('users.name ILIKE ?', "%#{search}%").or(
        teams_by_level_and_tag.where('startups.name ILIKE ?', "%#{search}%")
      ).or(teams_by_level_and_tag.where('users.email ILIKE ?', "%#{search}%"))
    else
      teams_by_level_and_tag
    end
  end

  private

  def resource_school
    course&.school
  end

  def course
    @course ||= Course.find(course_id)
  end

  def teams_by_tag
    teams = course.startups.active
      .select('"startups".*, LOWER(startups.name) AS startup_name')
      .joins(founders: :user)
      .includes(:faculty_startup_enrollments, founders: { user: { avatar_attachment: :blob } })
      .distinct.order("#{sort_by_string} #{sort_direction_string}")

    if tags.present?
      tagged = ActsAsTaggableOn::Tagging.joins(:tag)
        .where(tags: {name: tags})
        .where("taggings.taggable_type <> 'School'")
        .select("taggings.taggable_id, taggings.taggable_type")
        .group_by(&:taggable_type)
        .map{|type, items| [type, items.map(&:taggable_id)]}
        .to_h
      teams = teams.where(users: {id: tagged.fetch("User", []) }).or(teams.where(startups: {id: tagged.fetch("Startup", [])}))
    end

    teams
  end

  def teams_by_level_and_tag
    level_id.present? ? teams_by_tag.where(level_id: level_id) : teams_by_tag
  end

  def sort_direction_string
    case sort_direction
    when 'Ascending'
      'ASC'
    when 'Descending'
      'DESC'
    else
      raise "#{sort_direction} is not a valid sort direction"
    end
  end

  def sort_by_string
    case sort_by
    when 'name'
      'startup_name'
    when 'created_at'
      'created_at'
    when 'updated_at'
      'updated_at'
    else
      raise "#{sort_by} is not a valid sort criterion"
    end
  end
end
