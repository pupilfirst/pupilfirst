class AdmissionsController < ApplicationController
  # GET /apply
  def apply
    @founder_registration = Founders::RegistrationForm.new
  end

  # POST /apply/register
  def register
    form = Founders::RegistrationForm.new

    if form.validate(params[:founders_registration])
      begin
        founder = form.save
      rescue Postmark::InvalidMessageError
        form.errors[:base] << t('batch_application.create.email_error')
        render 'apply'
      else
        # Sign in user immediately to allow him to proceed to screening.
        sign_in founder.user

        redirect_to admissions_screening_path
      end
    else
      render 'apply'
    end
  end
end
