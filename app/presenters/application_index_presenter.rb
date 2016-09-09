class ApplicationIndexPresenter
  def initialize(batch_applicant)
    @batch_applicant = batch_applicant
  end

  def batch_application_form
    @batch_application_form ||= BatchApplicationForm.new(BatchApplicant.new)
  end

  def old_applications
    return [] if @batch_applicant.nil? || @batch_applicant.batch_applications.blank?

    applications = @batch_applicant.batch_applications.select do |application|
      application.status.in? [:expired, :complete, :rejected]
    end

    applications.map { |application| BatchApplicationDecorator.decorate(application) }
  end
end
