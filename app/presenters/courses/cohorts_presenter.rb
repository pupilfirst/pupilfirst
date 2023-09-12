class Courses::CohortsPresenter < ApplicationPresenter
  def initialize(view_context, course, status)
    @course = course
    @status = status || "active"
    super(view_context)
  end

  def students
    Student.where(cohort: cohorts)
  end

  def cohorts
    validate_status

    @cohorts ||=
      if current_school_admin.present?
        @course.cohorts
      else
        current_user.faculty.cohorts.where(course: @course)
      end.public_send(@status)
  end

  def paged_cohorts
    paged = cohorts.page(params[:page]).per(24)
    paged = cohorts.page(paged.total_pages).per(24) if paged.out_of_range?
    paged
  end

  def validate_status
    return if %w[active ended].include?(@status)

    raise ArgumentError, "Invalid status #{@status}"
  end

  def page_title
    I18n.t("presenters.courses.cohorts.page_title", course_name: @course.name)
  end
end
