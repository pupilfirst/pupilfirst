class GraduationsController < ApplicationController
  # GET /graduations/preselection
  def preselection
    @startup = current_startup.decorate
    @founder = current_founder.decorate

    @form = if @startup.agreements_verified?
      Graduations::PreselectionStageSubmissionForm.new(@startup)
    elsif params[:update_profile]
      founder = @startup.founders.find(params[:update_profile])
      Graduations::PreselectionStageApplicantForm.new(founder)
    end
  end

  # POST /graduations/preselection
  def preselection_submit
    @form = Graduations::PreselectionStageSubmissionForm.new(current_startup)

    if @form.validate(params[:admissions_preselection_stage_submission])
      @form.save(current_founder)
      flash[:success] = 'Startup agreements were successfully saved.'
      redirect_to student_dashboard_path(from: 'preselection_submit')
    else
      @form.save_partnership_deed
      flash[:error] = 'We were unable to save details because of errors. Please try again.'

      @founder = current_founder.decorate
      @startup = current_startup.decorate
      render 'preselection'
    end
  end

  # PATCH /admissions/update_founder
  def update_founder
    founder_params = params[:admissions_preselection_stage_applicant]
    founder = current_startup.founders.find(founder_params[:id])
    @form = Graduations::PreselectionStageApplicantForm.new(founder)

    if @form.validate(founder_params)
      @form.save
      flash[:success] = 'Applicant details were successfully saved.'
      redirect_to admissions_preselection_path
    else
      # Special dispensation, since this form can have up to four file fields. It would be super-irritating to users to
      # lose uploads to validation failure.
      @form.save_uploaded_files
      flash[:error] = 'We were unable to save applicant details because of errors. Please try again.'

      @founder = current_founder.decorate
      @startup = current_startup.decorate
      render 'preselection'
    end
  end

  # respond with PDF version of the partnership deed created using Prawn
  def partnership_deed
    @startup = current_startup.decorate

    unless @startup.partnership_deed_ready?
      flash[:error] = 'Could not generate Partnership Deed. Ensure details of all founders are provided!'
      redirect_to admissions_preselection_path
      return
    end

    respond_to do |format|
      format.pdf do
        pdf = Startups::PartnershipDeedPdfBuilderService.build(current_startup)
        send_data pdf.to_pdf, type: 'application/pdf', filename: 'Partnership_Deed', disposition: 'inline'
      end
    end
  end

  # respond with PDF version of the digital incubation services agreement created using Prawn
  def incubation_agreement
    @startup = current_startup.decorate

    unless @startup.incubation_agreement_ready?
      flash[:error] = 'Could not generate Agreement. Ensure details of all founders are provided!'
      redirect_to admissions_preselection_path
      return
    end

    respond_to do |format|
      format.pdf do
        agreement_pdf = Startups::IncubationAgreementPdfBuilderService.build(@startup)
        send_data agreement_pdf.to_pdf, type: 'application/pdf', filename: 'Incubation_Agreement', disposition: 'inline'
      end
    end
  end
end
