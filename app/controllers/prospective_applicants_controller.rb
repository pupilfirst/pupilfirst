class ProspectiveApplicantsController < ApplicationController
  # POST /prospective_applicant
  def create
    form ||= ProspectiveApplicants::RegistrationForm.new(ProspectiveApplicant.new)

    if form.validate(params[:prospective_applicants_registration])
      begin
        prospective_applicant = form.save
      rescue Postmark::InvalidMessageError
        flash[:error] = t('admissions.register.email_error')
      else
        session[:prospective_applicant_email] = prospective_applicant.email
        flash[:success] = 'Your interest has been registered successfully.'
      end
    else
      flash[:error] = "There were problems with your submission: #{form.errors.full_messages.join(', ')}"
    end

    redirect_to join_path
  end
end
