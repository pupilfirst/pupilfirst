module Schools
  module Curricula
    class ShowPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def evaluation_criteria
        @course.evaluation_criteria.select(:id, :name, :description)
      end
    end
  end
end
