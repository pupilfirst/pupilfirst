module Schools
  class ShowPresenter < ApplicationPresenter
    def student_count
      Founder.joins(startup: { level: :course }).where(courses: { id: view.current_school.courses.select(:id) }).count
    end
  end
end
