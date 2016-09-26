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

  def applications_open?
    Batch.open_for_applications.any?
  end

  def next_batch_number
    @next_batch_number ||= Batch.order('created_at DESC').first.batch_number + 1
  end
end
