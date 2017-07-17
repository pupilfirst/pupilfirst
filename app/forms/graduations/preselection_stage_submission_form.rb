module Graduations
  class PreselectionStageSubmissionForm < Reform::Form
    property :courier_name, validates: { presence: true }
    property :courier_number, validates: { presence: true }
    property :partnership_deed, validates: { presence: true }
    property :payment_reference, validates: { presence: true }

    def save_partnership_deed
      return if errors.keys.include? :partnership_deed
      model.update(partnership_deed: partnership_deed)
    end

    def save(current_founder)
      model.update!(
        courier_name: courier_name,
        courier_number: courier_number,
        partnership_deed: partnership_deed,
        payment_reference: payment_reference
      )

      # update intercom last_applicant_event
      IntercomLastApplicantEventUpdateJob.perform_later(model.admin, 'agreements_sent') unless Rails.env.test?

      TimelineEvent.create!(
        founder: current_founder,
        startup: model,
        description: 'Pre-selection information has been submitted to the SV.CO team',
        timeline_event_type: TimelineEventType.team_update,
        event_on: Time.zone.now,
        iteration: model.iteration
      )
    end

    def deed_help_extra
      "Upload another file if you wish to replace <code>#{model.filename(:partnership_deed)}</code><br/>" if model.partnership_deed.present?
    end
  end
end
