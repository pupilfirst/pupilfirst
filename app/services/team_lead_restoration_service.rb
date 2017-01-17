# This service will restore team lead entries to applications with payment entries if they're missing. It retrieves the
# team lead's email and name from Instamojo's API through the stored payment details, creates the applicant, and
# re-links it as application's lead and payment's applicant.
class TeamLeadRestorationService
  include Loggable

  def initialize(dry_run: true)
    @dry_run = dry_run
  end

  def execute
    applications_without_team_lead = BatchApplication.includes(:team_lead).where(batch_applicants: { id: nil })

    if applications_without_team_lead.any?
      headless_applications_with_payment = applications_without_team_lead.joins(:payment)

      log "There are #{applications_without_team_lead.count} applications without team lead, of which #{headless_applications_with_payment.count} have payment entries."

      headless_applications_with_payment.each do |headless_application|
        log "Processing BatchApplication##{headless_application.id}..."

        response = details_from_instamojo(headless_application)

        if response['success']
          restore_applicant(headless_application, response)
        else
          log "Could not retrieve email address from Instamojo for BatchApplication##{headless_application.id}"
        end
      end
    else
      log 'There are no batch applications without team lead. Exiting.'
    end
  end

  def details_from_instamojo(application)
    instamojo_payment_request_id = application.payment.instamojo_payment_request_id
    instamojo.raw_payment_request_details(instamojo_payment_request_id)
  end

  def instamojo
    @instamojo ||= Instamojo.new
  end

  def restore_applicant(application, instamojo_response)
    name = instamojo_response['payment_request']['buyer_name']
    email = instamojo_response['payment_request']['email']

    log "Restoring applicant as team lead: #{name} <#{email}>"

    return if @dry_run

    applicant = application.batch_applicants.create!(
      email: email,
      name: name
    )

    # Link team lead to application and payment.
    application.update!(team_lead: applicant)
    application.payment.update!(batch_applicant: applicant)

    # Tag the applicant as 'restored'
    applicant.tag_list.add('restored')
    applicant.save!
  end
end
