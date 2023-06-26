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
    if @status == "active"
      @cohorts ||= @course.cohorts.active
    else
      @cohorts ||= @course.cohorts.ended
    end
  end
end
