class AdmissionsController < ApplicationController
  layout 'application_v2'
  before_action :skip_container, only: %i(founders founders_submit)

  # GET /apply
  def apply
    @form = Founders::RegistrationForm.new(Founder.new)
    @form.prepopulate(current_user) if current_user.present?
  end

  # POST /apply
  def register
    @form = Founders::RegistrationForm.new(Founder.new)

    if @form.validate(params[:founders_registration])
      begin
        founder = @form.save
      rescue Postmark::InvalidMessageError
        @form.errors[:base] << t('batch_application.create.email_error')
        render 'apply'
      else
        # Sign in user immediately to allow him to proceed to screening.
        sign_in founder.user

        redirect_to dashboard_founder_path
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
    authorize :admissions

    Admissions::CompleteTargetService.new(current_founder, Target::KEY_ADMISSIONS_SCREENING).execute

    flash[:success] = 'Screening target has been marked as completed!'
    redirect_to dashboard_founder_path
  end

  # GET /admissions/founders
  def founders
    authorize :admissions
    @form = Admissions::FoundersForm.new(current_founder.startup)
    @form.prepopulate
  end

  # POST /admissions/founders
  def founders_submit
    authorize :admissions
  end

  private

  def skip_container
    @skip_container = true
  end
end
