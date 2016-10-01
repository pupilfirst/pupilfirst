class IntercomApplicantUpdateJob < ActiveJob::Base
  queue_as :default
  attr_reader :applicant

  def perform(applicant)
    return if Rails.env.test?

    @applicant = applicant
    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: applicant.email, name: applicant.name)

    intercom.add_tag_to_user(user, 'Applicant')
    intercom.add_note_to_user(user, 'Auto-tagged as <em>Applicant</em>')
    intercom.update_user(user, phone: applicant.phone, college: applicant_college_name, batch: open_batch_name, university: applicant_university)
  end

  def open_batch_name
    batch = Batch.open_batch
    "#{batch.batch_number} #{batch.theme}"
  end

  def applicant_college_name
    applicant.college_text || applicant.college.name
  end

  def applicant_university
    applicant&.college&.replacement_university&.name
  end
end
