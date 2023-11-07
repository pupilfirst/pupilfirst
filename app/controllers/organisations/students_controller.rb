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
      student = authorize Student.find(params[:id])
      @user = student.user
      @user_standings =
        @user
          .user_standings
          .includes(:standing)
          .where(archived_at: nil)
          .order(created_at: :desc)
      @school_default_standing =
        Standing.find_by(school: current_school, default: true)
      @current_standing =
        @user_standings.first&.standing || @school_default_standing
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
