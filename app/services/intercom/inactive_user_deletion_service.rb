module Intercom
  # The service removes inactive users/leads from Intercom and uploads the contacts to sendinblue
  class InactiveUserDeletionService
    def initialize
      @intercom_client = Intercom::Client.new(token: ENV.fetch('INTERCOM_ACCESS_TOKEN'))
      @sendinblue_client = Sendinblue::Mailin.new('https://api.sendinblue.com/v2.0', ENV.fetch('SENDINBLUE_API_KEY'))
    end

    def execute
      upload_contacts_to_sendinblue
      delete_inactive_users
      delete_inactive_leads
    end

    private

    def upload_contacts_to_sendinblue
      return if contacts_to_upload.blank?
      contacts_to_upload.each do |contact|
        @sendinblue_client.create_update_user(contact)
      end
    end

    # extract user information from intercom stale users/leads and create a contact list in the format
    # required by sendinblue
    # rubocop:disable Metrics/CyclomaticComplexity
    def contacts_to_upload
      contact_list = []
      stale_users_and_leads = stale_users + stale_leads
      return if stale_users_and_leads.blank?
      stale_users_and_leads.each_with_index do |stale_user, index|
        user_details = {}
        # ignore stale leads without email, as email is mandatory for sendinblue contact
        next if stale_user.email.blank?
        user_details['email'] = stale_user.email
        user_details['attributes'] = { 'NAME' => stale_user.name || '',
                                       'PHONE' => stale_user.custom_attributes['phone'] || 0,
                                       'COLLEGE' => stale_user.custom_attributes['college'] || '',
                                       'UNIVERSITY' => stale_user.custom_attributes['university'] || '' }
        user_details['listid'] = [4]
        contact_list[index] = user_details
      end
      contact_list
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
      @stale_users ||= rescued_call { @intercom_client.users.find_all(segment_id: get_segment_id('Stale Users')).to_a }
    end

    def stale_leads
      @stale_leads ||= rescued_call { @intercom_client.users.find_all(segment_id: get_segment_id('Stale Leads')).to_a }
    end

    def rescued_call
      yield
    rescue Intercom::ResourceNotFound, Intercom::MultipleMatchingUsersError
      raise
    rescue Intercom::IntercomError => e
      raise Exceptions::IntercomError, "#{e.class}: #{e.message}}"
    end

    def get_segment_id(segment_name)
      segment_id = nil
      rescued_call { @intercom_client.segments.all }.each do |segment|
        next unless segment.name == segment_name
        segment_id = segment.id
      end
      segment_id
    end
  end
end
