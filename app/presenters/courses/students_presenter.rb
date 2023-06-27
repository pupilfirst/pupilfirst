class Courses::StudentsPresenter < ApplicationPresenter
  def initialize(view_context, course, status)
    @course = course
    @status = status || "active"
    super(view_context)
  end

  def students
    Founder.where(cohort: cohorts)
  end

  def cohorts
    @cohorts ||=
      if @status == "active"
        @course.cohorts.active
      else
        @course.cohorts.ended
      end
  end

  def paged_cohorts
    paged = cohorts.page(params[:page]).per(24)
    paged = cohorts.page(paged.total_pages).per(24) if paged.out_of_range?
    paged
  end
end
