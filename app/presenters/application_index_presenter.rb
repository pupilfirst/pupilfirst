class ApplicationIndexPresenter
  def initialize(batch_applicant)
    @batch_applicant = batch_applicant
  end

  def batch_application_form
    form = BatchApplicationForm.new(BatchApplication.new)
    form.prepopulate!(team_lead: BatchApplicant.new)
    form
  end

  def old_applications
    return [] if @batch_applicant.nil? || @batch_applicant.batch_applications.blank?

    applications = @batch_applicant.batch_applications.select do |application|
      application.status.in? [:expired, :complete, :rejected]
    end

    applications.map { |application| BatchApplicationDecorator.decorate(application) }
  end
end
