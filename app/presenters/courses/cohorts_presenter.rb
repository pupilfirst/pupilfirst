class Courses::CohortsPresenter < ApplicationPresenter
  attr_reader :status

  def initialize(view_context, course, status)
    @course = course
    @status = status == "ended" ? "ended" : "active"
    super(view_context)
  end

  def students
    Student.where(cohort: cohorts)
  end

  def cohorts
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

  def page_title
    I18n.t("presenters.courses.cohorts.page_title", course_name: @course.name)
  end
end
