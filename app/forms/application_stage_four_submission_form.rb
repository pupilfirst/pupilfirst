class ApplicationStageFourSubmissionForm < Reform::Form
  property :courier_name, validates: { presence: true }
  property :courier_number, validates: { presence: true }
  property :partnership_deed, validates: { presence: true }
  property :payment_reference, validates: { presence: true }

  def save_partnership_deed
    return if errors.keys.include? :partnership_deed
    model.update(partnership_deed: partnership_deed)
  end

  def save
    ApplicationSubmission.transaction do
      # create a placebo submission to mark stage complete
      model.application_submissions.create!(
        application_stage: ApplicationStage.shortlist_stage,
        notes: "Fee payment reference: #{payment_reference}. Agreement couriered via #{courier_name} (reference: #{courier_number})"
      )

      # update batch application with given details
      super
    end

    # update intercom last_applicant_event
    IntercomLastApplicantEventUpdateJob.perform_later(model.team_lead, 'agreements_sent') unless Rails.env.test?
  end

  def deed_help_extra
    model.partnership_deed.present? ? "Upload another file if you wish to replace <code>#{model.partnership_deed.file.filename}</code><br/>" : ''
  end
end
