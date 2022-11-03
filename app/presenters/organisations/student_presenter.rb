module Organisations
  class StudentPresenter < ApplicationPresenter
    def initialize(view_context, student)
      @student = student
      super(view_context)
    end

    def student
      @student
    end
  end
end
