# This service updates all relevant attributes of Intercom Users who are associated with Batch Applicants
#
# Updated info include Batch, College, Univeristy, and Last Applicant Event
class IntercomUserUpdateService < BaseService
  attr_reader :intercom, :user, :batch_applicant

  def self.update_all
    new.update_all
  end

  def initialize
    @intercom = IntercomClient.new
  end

  def update_all
    BatchApplicant.all.each do |applicant|
      @batch_applicant = applicant.decorate
      update_intercom_user if intercom_user?
    end

    true
  end

  private

  def intercom_user?
    @user = intercom.find_user batch_applicant.email
    return true if user.present?

    log "No intercom user with email #{batch_applicant.email} found. Skipping..."
    false
  end

  def update_intercom_user
    update_basic_info
    update_last_applicant_event if last_applicant_event?
  end

  def update_basic_info
    log "Updating basic info of #{batch_applicant.email}"
    intercom.update_user(user, phone: batch_applicant.phone, college: batch_applicant.college_name, batch: batch_applicant.batch_name, university: batch_applicant.university_name)
  end

  def last_applicant_event?
    return true if batch_applicant.last_applicant_event.present?

    log "No last_applicant_event found for #{batch_applicant.email}"
    false
  end

  def update_last_applicant_event
    log "Updating last_applicant_event of #{batch_applicant.email}"
    IntercomLastApplicantEventUpdateJob.perform_now(batch_applicant, batch_applicant.last_applicant_event)
  end
end
