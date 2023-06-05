class Courses::StudentsPresenter < ApplicationPresenter
  def initialize(view_context, course)
    @course = course
    super(view_context)
  end

  def active_students
    Founder.where(cohort: active_cohorts)
  end

  def active_cohorts
    @active_cohorts ||= @course.cohorts.active
  end
end
