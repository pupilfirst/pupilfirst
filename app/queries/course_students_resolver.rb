class CourseStudentsResolver < ApplicationQuery
  include FilterUtils

  property :course_id
  property :filter_string

  def course_students
    students
  end

  private

  def students
    scope = course.students

    scope =
      if current_school_admin.present? &&
           filter[:request_origin] == "review_interface"
        scope.where(cohort_id: current_user.faculty&.cohorts)
      else
        scope
      end

    case filter[:status]&.downcase
    when "active"
      scope = scope.active
    when "dropped"
      scope = scope.dropped
    when "ended"
      scope = scope.ended
    else
      scope
    end

    scope = scope.joins(:user) if filter[:name].present? ||
      filter[:email].present? || filter[:user_tags].present?

    scope = scope.where(cohort_id: cohort.id) if cohort.present?
    scope =
      scope.joins(:faculty_student_enrollments).where(
        { faculty_student_enrollments: { faculty_id: personal_coach.id } }
      ) if personal_coach.present?
    scope = scope.where(team_id: nil) if filter[:not_teamed_up].present?
    scope = scope.where("users.name ILIKE ?", "%#{filter[:name]}%") if filter[
      :name
    ].present?
    scope = scope.where("users.email ILIKE ?", "%#{filter[:email]}%") if filter[
      :email
    ].present?
    scope = scope.tagged_with(filter[:student_tags].split(",")) if filter[
      :student_tags
    ].present?

    scope =
      scope.where(
        users: {
          id:
            resource_school
              .users
              .tagged_with(filter[:user_tags].split(","))
              .select(:id)
        }
      ) if filter[:user_tags].present?

    if filter[:sort_by].present?
      scope.includes(:user).order("#{sort_by_string}")
    else
      scope.order("students.created_at DESC")
    end
  end

  def resource_school
    course&.school
  end

  def cohort
    if filter[:cohort].blank? || id_from_filter_value(filter[:cohort]).blank?
      return
    end

    course.cohorts.find_by(id: id_from_filter_value(filter[:cohort]))
  end

  def personal_coach
    if filter[:personal_coach].blank? ||
         id_from_filter_value(filter[:personal_coach]).blank?
      return
    end

    course.faculty.find_by(id: id_from_filter_value(filter[:personal_coach]))
  end

  def course
    @course ||= Course.find(course_id)
  end

  def sort_by_string
    case filter[:sort_by]
    when "Name"
      "users.name ASC"
    when "First Created"
      "students.created_at ASC"
    when "Last Created"
      "students.created_at DESC"
    when "First Updated"
      "students.updated_at ASC"
    when "Last Updated"
      "students.updated_at DESC"
    else
      raise "#{filter[:sort_by]} is not a valid sort criterion"
    end
  end

  def authorized?
    return true if current_school_admin.present?

    current_user.faculty&.courses&.exists?(id: course)
  end
end
