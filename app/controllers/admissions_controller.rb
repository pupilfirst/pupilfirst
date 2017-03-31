class AdmissionsController < ApplicationController
  layout 'application_v2'

  # GET /apply
  def apply
    @founder_registration_form = Founders::RegistrationForm.new(Founder.new)
    @founder_registration_form.prepopulate!(current_user) if current_user.present?
  end

  # POST /apply
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

  # GET /admissions/screening
  def screening
    authorize :admissions
  end

  # POST /admissions/screening
  def screening_submit
    # TODO: Do stuff.
  end
end
