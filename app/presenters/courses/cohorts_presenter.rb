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
    @cohorts ||=
      if @status == "active"
        current_user.faculty.cohorts.where(course: @course).active
      else
        current_user.faculty.cohorts.where(course: @course).ended
      end
  end

  def paged_cohorts
    paged = cohorts.page(params[:page]).per(24)
    paged = cohorts.page(paged.total_pages).per(24) if paged.out_of_range?
    paged
  end

  def page_title
    I18n.t("shared.cohorts") + " | #{@course.name}"
  end
end
