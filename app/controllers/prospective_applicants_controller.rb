class ProspectiveApplicantsController < ApplicationController
  layout 'application_v2'

  # POST /prospective_applicant
  def create
    @form ||= ProspectiveApplicants::RegistrationForm.new(ProspectiveApplicant.new)

    if @form.validate(params[:prospective_applicants_registration])
      prospective_applicant = @form.save
      session[:prospective_applicant_email] = prospective_applicant.email
      redirect_to join_path
    else
      @prospective_applicant = ProspectiveApplicant.new.decorate
      render 'admissions/join'
    end
  end
end
