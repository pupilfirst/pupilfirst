module Organisations
  class StudentsController < ApplicationController
    before_action :authenticate_user!
    layout "student"

    # GET /org/students/:id
    def show
      student = authorize Student.find(params[:id])
      @presenter = StudentPresenter.new(view_context, student)
    end

    # GET /org/students/:id/submissions
    def submissions
      student = authorize Student.find(params[:id])
      @presenter = StudentPresenter.new(view_context, student)
      raise_not_found if @presenter.reviewed_submissions.empty?
    end

    # GET /org/students/:id/standing
    def standing
      @student = authorize Student.find(params[:id])
      @presenter = Users::StandingPresenter.new(view_context, @student.user)
    end

    private

    def policy_scope(scope)
      super([:organisations, scope])
    end

    def authorize(record, query = nil)
      super([:organisations, record], query)
    end
  end
end
