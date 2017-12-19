class ProspectiveApplicantsController < ApplicationController
  # POST /prospective_applicant
  def create
    form ||= ProspectiveApplicants::RegistrationForm.new(ProspectiveApplicant.new)

    if verify_recaptcha(model: form, secret_key: Rails.application.secrets.dig(:google, :recaptcha, :invisible, :secret_key))
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
    end

    redirect_to join_path
  end
end
