module Intercom
  # The service removes inactive users/leads from Intercom and uploads the contacts to sendinblue
  class InactiveUserDeletionService
    include Loggable

    def initialize
      @intercom_client = Intercom::Client.new(token: Rails.application.secrets.intercom_access_token)
      @sendinblue_client = Sendinblue::Mailin.new('https://api.sendinblue.com/v2.0', Rails.application.secrets.sendinblue_api_key)
    end

    def execute
      log 'Uploading contacts to SendinBlue...'
      upload_contacts_to_sendinblue

      log 'Deleting inactive users from Intercom...'
      delete_inactive_users

      log 'Deleting inactive leads from Intercom...'
      delete_inactive_leads
    end

    private

    def upload_contacts_to_sendinblue
      return if contacts_to_upload.blank?

      contacts_to_upload.each do |contact|
        @sendinblue_client.create_update_user(contact)
      end
    end

    # Extract user information from intercom stale users/leads and create a contact list in the format required by SendinBlue.
    def contacts_to_upload
      stale_contacts = stale_users + stale_leads
      log "There are #{stale_contacts.count} contacts to upload..."

      stale_contacts.map do |stale_user|
        next if stale_user.email.blank?

        {
          email: stale_user.email,
          listid: [4],
          attributes: sendinblue_attributes(stale_user)
        }
      end - [nil]
    end

    def sendinblue_attributes(user)
      attributes = {}
      attributes[:NAME] = user.name if user.name.present?
      attributes[:PHONE] = user.custom_attributes['phone'] if user.custom_attributes['phone'].present?
      attributes[:PHONE] = user.phone if user.phone.present?
      attributes[:COLLEGE] = user.custom_attributes['college'] if user.custom_attributes['college'].present?
      attributes[:UNIVERSITY] = user.custom_attributes['university'] if user.custom_attributes['university'].present?
      attributes
    end

    def delete_inactive_users
      return if stale_users.blank?
      @intercom_client.users.submit_bulk_job(delete_items: @stale_users)
    end

    def delete_inactive_leads
      return if stale_leads.blank?
      @intercom_client.users.submit_bulk_job(delete_items: @stale_leads)
    end

    def stale_users
      @stale_users ||= @intercom_client.users.find_all(segment_id: segment_id('Stale Users')).to_a
    end

    def stale_leads
      @stale_leads ||= @intercom_client.users.find_all(segment_id: segment_id('Stale Leads')).to_a
    end

    def segment_id(segment_name)
      segment_id = nil

      @intercom_client.segments.all.each do |segment|
        next unless segment.name == segment_name
        segment_id = segment.id
      end

      segment_id
    end
  end
end
