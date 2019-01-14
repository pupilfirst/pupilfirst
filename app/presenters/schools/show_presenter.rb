module Schools
  class ShowPresenter < ApplicationPresenter
    def student_count
      view.current_school.founders.count
    end
  end
end
