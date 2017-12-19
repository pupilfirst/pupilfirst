module Admissions
  class ProspectiveApplicantFormPresenter < ApplicationPresenter
    def initialize(view_context)
      @join_presenter = Admissions::ApplicationFormPresenter.new(view_context)
      super(view_context)
    end

    delegate :college_collection, :selected_college, to: :@join_presenter

    def submitted?
      view.session[:prospective_applicant_email].present?
    end
  end
end
