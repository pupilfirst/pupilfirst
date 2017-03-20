module Intercom
  # The service removes inactive users/leads from Intercom and uploads the contacts to sendinblue
  class InactiveUserDeletionService
    include Loggable

    def initialize(mock: false)
      @mock = mock
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
        if @mock
          log "@sendinblue_client.create_update_user({ email: '#{contact[:email]}', ...})"
        else
          @sendinblue_client.create_update_user(contact)
        end
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
          listid: ENV.fetch('SENDINBLUE_IMPORT_LIST_ID'),
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
      if @mock
        log "@intercom_client.users.submit_bulk_job(delete_items: [#{@stale_users.count} users])"
      else
        @intercom_client.users.submit_bulk_job(delete_items: @stale_users)
      end
    end

    def delete_inactive_leads
      return if stale_leads.blank?
      if @mock
        log "@intercom_client.users.submit_bulk_job(delete_items: [#{@stale_leads.count} users])"
      else
        @intercom_client.users.submit_bulk_job(delete_items: @stale_leads)
      end
    end

    def stale_users
      @stale_users ||= @intercom_client.users.find_all(segment_id: segment_id('Stale Users')).to_a
    end

    def stale_leads
      @stale_leads ||= @intercom_client.users.find_all(segment_id: segment_id('Stale Leads')).to_a
    end

    def segment_id(segment_name)
      @intercom_client.segments.all.find { |segment| segment.name == segment_name }&.id
    end
  end
end
